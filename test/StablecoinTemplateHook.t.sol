// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {BaseTemplateTest} from "./BaseTemplateTest.t.sol";
import {TemplateDeployers} from "./TemplateDeployers.sol";
import {StablecoinTemplateHook} from "../src/hooks/StablecoinTemplateHook.sol";
import {StablecoinTemplateConfig} from "../src/framework/TemplateTypes.sol";
import {Unauthorized} from "../src/framework/TemplateErrors.sol";

contract StablecoinTemplateHookTest is BaseTemplateTest, TemplateDeployers {
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
}
