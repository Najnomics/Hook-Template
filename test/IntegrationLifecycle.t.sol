// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {BaseTemplateTest} from "./BaseTemplateTest.t.sol";
import {TemplateDeployers} from "./TemplateDeployers.sol";
import {StablecoinTemplateHook} from "../src/hooks/StablecoinTemplateHook.sol";
import {RWATemplateHook} from "../src/hooks/RWATemplateHook.sol";
import {LongTailTemplateHook} from "../src/hooks/LongTailTemplateHook.sol";
import {LongTailTemplateConfig, RWATemplateConfig} from "../src/framework/TemplateTypes.sol";

contract IntegrationLifecycleTest is BaseTemplateTest, TemplateDeployers {
    function test_StablecoinLifecycleE2E() public {
        _bootstrapCore();
        (StablecoinTemplateHook hook,) = deployStablecoin(IPoolManager(address(manager)), address(this));
        _initializePool(IHooks(address(hook)), 500_000 ether);
        _mintAndApprove(alice, STARTING_BALANCE);

        _swapExactIn(alice, 8_000 ether, true, bytes(""));
        _swapExactOut(alice, 1_000 ether, false, bytes(""));

        (,,,,, uint256 cumulativeVolume) = hook.guardState();
        assertGt(cumulativeVolume, 0);
        assertEq(hook.supportedPoolId(), PoolId.unwrap(poolId));
    }

    function test_RWALifecycleE2E() public {
        _bootstrapCore();
        (RWATemplateHook hook,) = deployRWA(IPoolManager(address(manager)), address(this));
        _initializePool(IHooks(address(hook)), 500_000 ether);
        _mintAndApprove(alice, STARTING_BALANCE);

        address[] memory allowlist = new address[](1);
        allowlist[0] = address(swapRouter);
        hook.setAllowlist(allowlist, true);

        _swapExactIn(alice, 10_000 ether, true, bytes(""));

        RWATemplateConfig memory cfg = defaultRWAConfig();
        cfg.sessionOpenSeconds = 1;
        cfg.sessionCloseSeconds = 2;
        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        vm.warp(100);
        vm.expectRevert();
        _swapExactIn(alice, 2_000 ether, true, bytes(""));
    }

    function test_LongTailLifecycleE2E() public {
        _bootstrapCore();
        (LongTailTemplateHook hook,) = deployLongTail(IPoolManager(address(manager)), address(this));
        _initializePool(IHooks(address(hook)), 500_000 ether);
        _mintAndApprove(alice, STARTING_BALANCE);

        LongTailTemplateConfig memory cfg = defaultLongTailConfig();
        cfg.initialMaxTrade = 50_000 ether;
        cfg.launchDuration = 1 hours;
        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        _swapExactIn(alice, 2_000 ether, true, bytes(""));
        assertTrue(hook.launchMode());

        vm.warp(block.timestamp + 2 hours);
        _swapExactIn(alice, 2_000 ether, false, bytes(""));
        assertFalse(hook.launchMode());
    }
}
