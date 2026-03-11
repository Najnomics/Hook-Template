// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {BaseTemplateTest} from "./BaseTemplateTest.t.sol";
import {TemplateDeployers} from "./TemplateDeployers.sol";
import {LongTailTemplateHook} from "../src/hooks/LongTailTemplateHook.sol";
import {LongTailTemplateConfig} from "../src/framework/TemplateTypes.sol";
import {InvalidConfig} from "../src/framework/TemplateErrors.sol";

contract LongTailTemplateHookTest is BaseTemplateTest, TemplateDeployers {
    LongTailTemplateHook internal hook;

    function setUp() public {
        _bootstrapCore();
        (hook,) = deployLongTail(IPoolManager(address(manager)), address(this));
        _initializePool(IHooks(address(hook)), 300_000 ether);
        _mintAndApprove(alice, STARTING_BALANCE);
    }

    function test_LaunchPhaseCapsLargeTrades() public {
        vm.expectRevert();
        _swapExactIn(alice, 20_000 ether, true, bytes(""));
    }

    function test_SegmentedOrderFlowCapsPerBlockVolume() public {
        LongTailTemplateConfig memory cfg = defaultLongTailConfig();
        cfg.initialMaxTrade = 50_000 ether;
        cfg.perBlockVolumeCap = 12_000 ether;

        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        _swapExactIn(alice, 8_000 ether, true, bytes(""));
        vm.expectRevert();
        _swapExactIn(alice, 8_000 ether, true, bytes(""));
    }

    function test_ModeTransitionsToNormalAfterLaunchDuration() public {
        LongTailTemplateConfig memory cfg = defaultLongTailConfig();
        cfg.initialMaxTrade = 100_000 ether;
        cfg.launchDuration = 1 hours;

        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        vm.warp(block.timestamp + 2 hours);
        _swapExactIn(alice, 5_000 ether, true, bytes(""));

        assertFalse(hook.launchMode());
        assertEq(hook.lastAppliedFee(), cfg.normalFee);
    }

    function test_ModeTransitionsByVolumeAndUpdatesFee() public {
        LongTailTemplateConfig memory cfg = defaultLongTailConfig();
        cfg.initialMaxTrade = 100_000 ether;
        cfg.launchDuration = 12 hours;
        cfg.volumeTransitionThreshold = 1_000 ether;

        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        _swapExactIn(alice, 2_000 ether, true, bytes(""));

        assertFalse(hook.launchMode());
        assertEq(hook.lastAppliedFee(), cfg.normalFee);
    }

    function test_InvalidLaunchTradePathReverts() public {
        LongTailTemplateConfig memory cfg = defaultLongTailConfig();
        cfg.initialMaxTrade = 100_000 ether;
        cfg.finalMaxTrade = 50_000 ether;

        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("LONGTAIL_MAX_TRADE_PATH")));
        hook.scheduleTemplateConfigUpdate(cfg);
    }
}
