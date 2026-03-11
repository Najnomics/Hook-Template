// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {TickMath} from "@uniswap/v4-core/src/libraries/TickMath.sol";
import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import {BaseTemplateTest} from "./BaseTemplateTest.t.sol";
import {TemplateDeployers} from "./TemplateDeployers.sol";
import {RWATemplateHook} from "../src/hooks/RWATemplateHook.sol";
import {RWATemplateConfig} from "../src/framework/TemplateTypes.sol";
import {Unauthorized, GuardViolation} from "../src/framework/TemplateErrors.sol";

contract RWATemplateHookTest is BaseTemplateTest, TemplateDeployers {
    RWATemplateHook internal hook;

    function setUp() public {
        _bootstrapCore();
        (hook,) = deployRWA(IPoolManager(address(manager)), address(this));
        _initializePool(IHooks(address(hook)), 300_000 ether);
        _mintAndApprove(alice, STARTING_BALANCE);
        _mintAndApprove(bob, STARTING_BALANCE);
    }

    function test_RevertWhenActorNotAllowlisted() public {
        vm.expectRevert();
        _swapExactIn(alice, 10_000 ether, true, bytes(""));
    }

    function test_AllowlistsActorAndSwaps() public {
        address[] memory accounts = new address[](1);
        accounts[0] = address(swapRouter);
        hook.setAllowlist(accounts, true);

        _swapExactIn(alice, 10_000 ether, true, bytes(""));
        _swapExactOut(alice, 1_000 ether, false, bytes(""));

        (,,,,, uint256 cumulativeVolume) = hook.guardState();
        assertGt(cumulativeVolume, 0);
    }

    function test_HookDataCannotSpoofAllowlistedActor() public {
        address[] memory accounts = new address[](1);
        accounts[0] = alice;
        hook.setAllowlist(accounts, true);

        vm.expectRevert();
        _swapExactIn(alice, 10_000 ether, true, abi.encodePacked(alice));
    }

    function test_SessionWindowGuard() public {
        RWATemplateConfig memory cfg = defaultRWAConfig();
        cfg.sessionOpenSeconds = 1;
        cfg.sessionCloseSeconds = 2;

        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        address[] memory accounts = new address[](1);
        accounts[0] = address(swapRouter);
        hook.setAllowlist(accounts, true);

        vm.warp(10);
        vm.expectRevert();
        _swapExactIn(alice, 10_000 ether, true, bytes(""));
    }

    function test_RejectUnauthorizedAllowlistMutation() public {
        address[] memory accounts = new address[](1);
        accounts[0] = bob;

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Unauthorized.selector, alice));
        hook.setAllowlist(accounts, true);
    }

    function test_OvernightSessionWindowAllowsSwap() public {
        RWATemplateConfig memory cfg = defaultRWAConfig();
        cfg.sessionOpenSeconds = 80;
        cfg.sessionCloseSeconds = 20;
        cfg.permissionedOnly = true;

        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        address[] memory accounts = new address[](1);
        accounts[0] = address(swapRouter);
        hook.setAllowlist(accounts, true);

        vm.warp(10);
        _swapExactIn(alice, 4_000 ether, true, bytes(""));
    }

    function test_TickJumpGuardTriggers() public {
        RWATemplateConfig memory cfg = defaultRWAConfig();
        cfg.maxTickJump = 1;
        cfg.maxSlippageBps = 10_000;

        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        address[] memory accounts = new address[](1);
        accounts[0] = address(swapRouter);
        hook.setAllowlist(accounts, true);

        (, int24 currentTick,,) = StateLibrary.getSlot0(IPoolManager(address(manager)), poolId);
        _setLastObservedTick(currentTick + 500);

        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(1 ether),
            sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
        });

        vm.prank(address(manager));
        vm.expectRevert(abi.encodeWithSelector(GuardViolation.selector, bytes32("RWA_TICK_JUMP")));
        hook.beforeSwap(address(swapRouter), poolKey, params, bytes(""));
    }

    function test_SlippageGuardTriggers() public {
        RWATemplateConfig memory cfg = defaultRWAConfig();
        cfg.maxTickJump = 1_000;
        cfg.maxSlippageBps = 1;

        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        address[] memory accounts = new address[](1);
        accounts[0] = address(swapRouter);
        hook.setAllowlist(accounts, true);

        (, int24 currentTick,,) = StateLibrary.getSlot0(IPoolManager(address(manager)), poolId);
        _setLastObservedTick(currentTick + 50);

        SwapParams memory params = SwapParams({
            zeroForOne: true,
            amountSpecified: -int256(1 ether),
            sqrtPriceLimitX96: TickMath.MIN_SQRT_PRICE + 1
        });

        vm.prank(address(manager));
        vm.expectRevert(abi.encodeWithSelector(GuardViolation.selector, bytes32("RWA_SLIPPAGE")));
        hook.beforeSwap(address(swapRouter), poolKey, params, bytes(""));
    }

    function test_SessionFeeUpdatePath() public {
        RWATemplateConfig memory cfg = defaultRWAConfig();
        cfg.sessionFee = 4_000;

        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        address[] memory accounts = new address[](1);
        accounts[0] = address(swapRouter);
        hook.setAllowlist(accounts, true);

        _swapExactIn(alice, 6_000 ether, true, bytes(""));
        assertEq(hook.lastAppliedFee(), 4_000);
    }

    function _setLastObservedTick(int24 observed) internal {
        bytes32 slot = vm.load(address(hook), bytes32(uint256(16)));
        uint256 upper = uint256(slot) & ~uint256(type(uint24).max);
        uint256 encoded = uint256(uint24(uint256(int256(observed))));
        vm.store(address(hook), bytes32(uint256(16)), bytes32(upper | encoded));
    }
}
