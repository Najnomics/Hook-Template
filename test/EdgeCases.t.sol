// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {PoolManager} from "@uniswap/v4-core/src/PoolManager.sol";
import {PoolSwapTest} from "@uniswap/v4-core/src/test/PoolSwapTest.sol";
import {PoolModifyLiquidityTest} from "@uniswap/v4-core/src/test/PoolModifyLiquidityTest.sol";
import {Currency} from "@uniswap/v4-core/src/types/Currency.sol";
import {HookMiner} from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import {MockERC20} from "solmate/src/test/utils/mocks/MockERC20.sol";
import {Vm} from "forge-std/Vm.sol";
import {BaseTemplateTest} from "./BaseTemplateTest.t.sol";
import {TemplateDeployers} from "./TemplateDeployers.sol";
import {StablecoinTemplateHook} from "../src/hooks/StablecoinTemplateHook.sol";
import {StablecoinTemplateConfig} from "../src/framework/TemplateTypes.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {Unauthorized, InvalidConfig} from "../src/framework/TemplateErrors.sol";

contract EdgeCasesTest is BaseTemplateTest, TemplateDeployers {
    StablecoinTemplateHook internal hook;

    function setUp() public {
        _bootstrapCore();
        (hook,) = deployStablecoin(IPoolManager(address(manager)), address(this));
        _initializePool(IHooks(address(hook)), 300_000 ether);
        _mintAndApprove(alice, STARTING_BALANCE);
    }

    function test_ZeroLiquidityPoolSwapReturnsZeroDelta() public {
        PoolManager freshManager = new PoolManager(address(this));
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();

        bytes memory ctor = abi.encode(IPoolManager(address(freshManager)), address(this), cfg);
        (, bytes32 salt) = HookMiner.find(
            address(this),
            Hooks.AFTER_INITIALIZE_FLAG | Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG,
            type(StablecoinTemplateHook).creationCode,
            ctor
        );

        StablecoinTemplateHook freshHook =
            new StablecoinTemplateHook{salt: salt}(IPoolManager(address(freshManager)), address(this), cfg);

        // Same bootstrap logic but no liquidity add.
        manager = freshManager;
        swapRouter = new PoolSwapTest(manager);
        liquidityRouter = new PoolModifyLiquidityTest(manager);
        token0 = new MockERC20("Token0", "TK0", 18);
        token1 = new MockERC20("Token1", "TK1", 18);
        if (address(token0) > address(token1)) (token0, token1) = (token1, token0);
        currency0 = Currency.wrap(address(token0));
        currency1 = Currency.wrap(address(token1));
        token0.mint(alice, 1_000_000 ether);
        token1.mint(alice, 1_000_000 ether);

        vm.startPrank(alice);
        token0.approve(address(swapRouter), type(uint256).max);
        token1.approve(address(swapRouter), type(uint256).max);
        vm.stopPrank();

        _initializePool(IHooks(address(freshHook)), 0);

        BalanceDelta delta = _swapExactIn(alice, 1_000 ether, true, bytes(""));
        assertEq(delta.amount0(), 0);
        assertEq(delta.amount1(), 0);
    }

    function test_RateLimitRepeatedSwaps() public {
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        cfg.base.maxSwapsPerWindow = 1;

        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        _swapExactIn(alice, 2_000 ether, true, bytes(""));

        vm.expectRevert();
        _swapExactIn(alice, 1_000 ether, true, bytes(""));
    }

    function test_MaxTradeBoundary() public {
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        cfg.base.maxTradeSize = 5_000 ether;

        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        _swapExactIn(alice, 5_000 ether, true, bytes(""));

        vm.expectRevert();
        _swapExactIn(alice, 5_001 ether, true, bytes(""));
    }

    function test_ConfigInvalidationAndUnauthorizedUpdate() public {
        StablecoinTemplateConfig memory invalidCfg = defaultStablecoinConfig();
        invalidCfg.stressFee = invalidCfg.normalFee - 1;

        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("STABLE_FEE_ORDER")));
        hook.scheduleTemplateConfigUpdate(invalidCfg);

        StablecoinTemplateConfig memory validCfg = defaultStablecoinConfig();
        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Unauthorized.selector, alice));
        hook.scheduleTemplateConfigUpdate(validCfg);
    }

    function test_PermissionBitMismatchRevertsAtDeployment() public {
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        vm.expectRevert();
        new StablecoinTemplateHook(IPoolManager(address(manager)), address(this), cfg);
    }

    function test_ConfigUpdatedEventTopics() public {
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        cfg.extremeFee = 4_000;

        vm.recordLogs();
        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 configUpdatedSig = keccak256("ConfigUpdated(bytes32,bytes32,bytes32,uint256)");
        bool found;
        for (uint256 i = 0; i < entries.length; i++) {
            if (entries[i].topics.length > 0 && entries[i].topics[0] == configUpdatedSig) {
                found = true;
                break;
            }
        }
        assertTrue(found);
    }
}
