// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {HookMiner} from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {BaseTemplateTest} from "./BaseTemplateTest.t.sol";
import {TemplateDeployers} from "./TemplateDeployers.sol";
import {StablecoinTemplateHook} from "../src/hooks/StablecoinTemplateHook.sol";
import {StablecoinTemplateConfig} from "../src/framework/TemplateTypes.sol";
import {Unauthorized, InvalidConfig} from "../src/framework/TemplateErrors.sol";

contract StablecoinTemplateHookTest is BaseTemplateTest, TemplateDeployers {
    uint160 internal constant LOCAL_TEMPLATE_FLAGS =
        Hooks.AFTER_INITIALIZE_FLAG | Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG;
    StablecoinTemplateHook internal hook;

    function setUp() public {
        _bootstrapCore();
        (hook,) = deployStablecoin(IPoolManager(address(manager)), address(this));
        _initializePool(IHooks(address(hook)), 300_000 ether);
        _mintAndApprove(alice, STARTING_BALANCE);
    }

    function test_TracksSwapGuardsAndFeeBand() public {
        _swapExactIn(alice, 25_000 ether, true, bytes(""));

        (,,,,, uint256 cumulativeVolume) = hook.guardState();
        assertGt(cumulativeVolume, 0);
        assertGt(hook.lastAppliedFee(), 0);
        assertEq(hook.supportedPoolId(), PoolId.unwrap(poolId));
    }

    function test_CircuitBreakerCooldownEnforced() public {
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        cfg.stressDeviation = 1;
        cfg.extremeDeviation = 1;
        cfg.circuitBreakerDeviation = 1;
        cfg.base.cooldownSeconds = 600;

        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        _swapExactIn(alice, 35_000 ether, true, bytes(""));

        vm.expectRevert();
        _swapExactIn(alice, 1_000 ether, true, bytes(""));
    }

    function test_RevertOnUnauthorizedConfigUpdate() public {
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Unauthorized.selector, alice));
        hook.scheduleTemplateConfigUpdate(cfg);
    }

    function test_OnlyPoolManagerCanCallHookEntrypoints() public {
        vm.expectRevert(bytes4(keccak256("NotPoolManager()")));
        hook.beforeSwap(
            address(this),
            poolKey,
            SwapParams({
                zeroForOne: true, amountSpecified: -int256(1 ether), sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
            }),
            bytes("")
        );
    }

    function test_RevertOnSecondPoolInitialization() public {
        MockERC20 t0 = new MockERC20("Alt0", "A0", 18);
        MockERC20 t1 = new MockERC20("Alt1", "A1", 18);
        if (address(t0) > address(t1)) (t0, t1) = (t1, t0);

        PoolKey memory secondPoolKey = PoolKey({
            currency0: Currency.wrap(address(t0)),
            currency1: Currency.wrap(address(t1)),
            fee: poolKey.fee,
            tickSpacing: poolKey.tickSpacing,
            hooks: IHooks(address(hook))
        });

        vm.expectRevert();
        manager.initialize(secondPoolKey, uint160(79228162514264337593543950336));
    }

    function test_BaseAndTemplateConfigStagingAreIndependent() public {
        StablecoinTemplateConfig memory templateCfg = defaultStablecoinConfig();
        templateCfg.extremeFee = 4_000;

        hook.scheduleTemplateConfigUpdate(templateCfg);
        assertTrue(hook.pendingTemplateConfigHash() != bytes32(0));
        assertEq(hook.pendingConfigHash(), bytes32(0));

        hook.scheduleBaseConfigUpdate(templateCfg.base);
        assertTrue(hook.pendingConfigHash() != bytes32(0));

        hook.applyTemplateConfigUpdate(templateCfg);
        hook.applyBaseConfigUpdate(templateCfg.base);

        assertEq(hook.pendingTemplateConfigHash(), bytes32(0));
        assertEq(hook.pendingConfigHash(), bytes32(0));
    }

    function test_TemplateIdAndAdminUpdate() public {
        assertEq(hook.templateId(), hook.TEMPLATE_ID());
        hook.setAdmin(bob);
        assertEq(hook.admin(), bob);
    }

    function test_SetAdminZeroReverts() public {
        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("ADMIN")));
        hook.setAdmin(address(0));
    }

    function test_CancelStagedConfigClearsBaseAndTemplate() public {
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        cfg.extremeFee = 3_500;
        cfg.base.maxTradeSize = 200_000 ether;

        hook.scheduleTemplateConfigUpdate(cfg);
        hook.scheduleBaseConfigUpdate(cfg.base);

        hook.cancelStagedConfig();

        assertEq(hook.pendingTemplateConfigHash(), bytes32(0));
        assertEq(hook.pendingTemplateConfigEta(), 0);
        assertEq(hook.pendingConfigHash(), bytes32(0));
        assertEq(hook.pendingConfigEta(), 0);
    }

    function test_BaseConfigHashMismatchReverts() public {
        StablecoinTemplateConfig memory cfgA = defaultStablecoinConfig();
        StablecoinTemplateConfig memory cfgB = defaultStablecoinConfig();
        cfgA.base.maxTradeSize = 180_000 ether;
        cfgB.base.maxTradeSize = 181_000 ether;

        hook.scheduleBaseConfigUpdate(cfgA.base);

        vm.expectRevert();
        hook.applyBaseConfigUpdate(cfgB.base);
    }

    function test_BaseConfigDelayRevertsBeforeEta() public {
        StablecoinTemplateConfig memory delayedCfg = defaultStablecoinConfig();
        delayedCfg.base.configUpdateDelay = 1 days;
        hook.scheduleTemplateConfigUpdate(delayedCfg);
        hook.applyTemplateConfigUpdate(delayedCfg);

        StablecoinTemplateConfig memory nextCfg = delayedCfg;
        nextCfg.base.maxTradeSize = 210_000 ether;
        hook.scheduleBaseConfigUpdate(nextCfg.base);

        vm.expectRevert();
        hook.applyBaseConfigUpdate(nextCfg.base);
    }

    function test_TemplateConfigHashMismatchReverts() public {
        StablecoinTemplateConfig memory cfgA = defaultStablecoinConfig();
        StablecoinTemplateConfig memory cfgB = defaultStablecoinConfig();
        cfgA.extremeFee = 3_500;
        cfgB.extremeFee = 3_600;

        hook.scheduleTemplateConfigUpdate(cfgA);

        vm.expectRevert();
        hook.applyTemplateConfigUpdate(cfgB);
    }

    function test_TemplateConfigDelayRevertsBeforeEta() public {
        StablecoinTemplateConfig memory delayedCfg = defaultStablecoinConfig();
        delayedCfg.base.configUpdateDelay = 1 days;
        hook.scheduleTemplateConfigUpdate(delayedCfg);
        hook.applyTemplateConfigUpdate(delayedCfg);

        StablecoinTemplateConfig memory nextCfg = delayedCfg;
        nextCfg.extremeFee = 3_900;
        hook.scheduleTemplateConfigUpdate(nextCfg);

        vm.expectRevert();
        hook.applyTemplateConfigUpdate(nextCfg);
    }

    function test_VolatilitySpikeElevatesFeeToStressBand() public {
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        cfg.stressDeviation = 1_000_000;
        cfg.extremeDeviation = 1_100_000;
        cfg.circuitBreakerDeviation = 1_200_000;
        cfg.volatilityThreshold = 1;
        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        _swapExactIn(alice, 45_000 ether, true, bytes(""));
        _swapExactIn(alice, 45_000 ether, false, bytes(""));
        _swapExactIn(alice, 45_000 ether, true, bytes(""));

        assertEq(hook.lastAppliedFee(), cfg.stressFee);
    }

    function test_CircuitBreakerGuardViaDirectBeforeSwap() public {
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        cfg.stressDeviation = 1;
        cfg.extremeDeviation = 1;
        cfg.circuitBreakerDeviation = 1;
        cfg.base.cooldownSeconds = 100;
        cfg.volatilityThreshold = 1_000_000;
        bytes memory constructorArgs = abi.encode(IPoolManager(address(manager)), address(this), cfg);
        (, bytes32 salt) =
            HookMiner.find(address(this), LOCAL_TEMPLATE_FLAGS, type(StablecoinTemplateHook).creationCode, constructorArgs);
        StablecoinTemplateHook localHook = new StablecoinTemplateHook{salt: salt}(IPoolManager(address(manager)), address(this), cfg);

        PoolKey memory localPoolKey = PoolKey({
            currency0: currency0,
            currency1: currency1,
            fee: poolKey.fee,
            tickSpacing: poolKey.tickSpacing,
            hooks: IHooks(address(localHook))
        });
        manager.initialize(localPoolKey, TickMath.getSqrtPriceAtTick(100));

        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(1 ether),
            sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
        });

        vm.prank(address(manager));
        localHook.beforeSwap(address(swapRouter), localPoolKey, params, bytes(""));

        vm.prank(address(manager));
        vm.expectRevert();
        localHook.beforeSwap(address(swapRouter), localPoolKey, params, bytes(""));
    }

    function test_InvalidDeviationOrderingReverts() public {
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        cfg.stressDeviation = 0;

        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("STABLE_DEV_ORDER")));
        hook.scheduleTemplateConfigUpdate(cfg);
    }

    function test_ZeroVolatilityThresholdReverts() public {
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        cfg.volatilityThreshold = 0;

        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("STABLE_VOL_THRESHOLD")));
        hook.scheduleTemplateConfigUpdate(cfg);
    }

    function test_InvalidBaseConfigFieldsRevert() public {
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        cfg.base.maxTradeSize = 0;
        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("MAX_TRADE")));
        hook.scheduleTemplateConfigUpdate(cfg);

        cfg = defaultStablecoinConfig();
        cfg.base.rateLimitWindow = 0;
        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("RATE_WINDOW")));
        hook.scheduleTemplateConfigUpdate(cfg);

        cfg = defaultStablecoinConfig();
        cfg.base.maxSwapsPerWindow = 0;
        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("MAX_SWAPS")));
        hook.scheduleTemplateConfigUpdate(cfg);

        cfg = defaultStablecoinConfig();
        cfg.base.configUpdateDelay = 7 days + 1;
        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("CONFIG_DELAY")));
        hook.scheduleTemplateConfigUpdate(cfg);
    }

    function test_ConstructorZeroAdminReverts() public {
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        bytes memory constructorArgs = abi.encode(IPoolManager(address(manager)), address(0), cfg);
        (, bytes32 salt) =
            HookMiner.find(address(this), LOCAL_TEMPLATE_FLAGS, type(StablecoinTemplateHook).creationCode, constructorArgs);

        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("ADMIN")));
        new StablecoinTemplateHook{salt: salt}(IPoolManager(address(manager)), address(0), cfg);
    }

    function test_StressBandFeeSelectedWithoutExtremeDeviation() public {
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        cfg.stressDeviation = 1;
        cfg.extremeDeviation = 1_000_000;
        cfg.circuitBreakerDeviation = 1_200_000;
        cfg.volatilityThreshold = 1_000_000;
        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        _swapExactIn(alice, 40_000 ether, true, bytes(""));
        _swapExactIn(alice, 10_000 ether, false, bytes(""));

        assertEq(hook.lastAppliedFee(), cfg.stressFee);
    }

    function test_UnsupportedPoolRevertsFromBeforeSwap() public {
        MockERC20 t0 = new MockERC20("Unsupported0", "U0", 18);
        MockERC20 t1 = new MockERC20("Unsupported1", "U1", 18);
        if (address(t0) > address(t1)) (t0, t1) = (t1, t0);

        PoolKey memory unsupportedPool = PoolKey({
            currency0: Currency.wrap(address(t0)),
            currency1: Currency.wrap(address(t1)),
            fee: poolKey.fee,
            tickSpacing: poolKey.tickSpacing,
            hooks: IHooks(address(hook))
        });

        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(1 ether),
            sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
        });

        vm.prank(address(manager));
        vm.expectRevert();
        hook.beforeSwap(address(swapRouter), unsupportedPool, params, bytes(""));
    }
}
