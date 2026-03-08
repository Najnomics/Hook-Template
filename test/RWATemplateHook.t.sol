// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {BaseTemplateTest} from "./BaseTemplateTest.t.sol";
import {TemplateDeployers} from "./TemplateDeployers.sol";
import {RWATemplateHook} from "../src/hooks/RWATemplateHook.sol";
import {RWATemplateConfig} from "../src/framework/TemplateTypes.sol";
import {Unauthorized} from "../src/framework/TemplateErrors.sol";

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
        _swapExactIn(alice, 10_000 ether, true, abi.encodePacked(alice));
    }

    function test_AllowlistsActorAndSwaps() public {
        address[] memory accounts = new address[](1);
        accounts[0] = alice;
        hook.setAllowlist(accounts, true);

        _swapExactIn(alice, 10_000 ether, true, abi.encodePacked(alice));
        _swapExactOut(alice, 1_000 ether, false, abi.encodePacked(alice));

        (,,,,, uint256 cumulativeVolume) = hook.guardState();
        assertGt(cumulativeVolume, 0);
    }

    function test_SessionWindowGuard() public {
        RWATemplateConfig memory cfg = defaultRWAConfig();
        cfg.sessionOpenSeconds = 1;
        cfg.sessionCloseSeconds = 2;

        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);

        address[] memory accounts = new address[](1);
        accounts[0] = alice;
        hook.setAllowlist(accounts, true);

        vm.warp(10);
        vm.expectRevert();
        _swapExactIn(alice, 10_000 ether, true, abi.encodePacked(alice));
    }

    function test_RejectUnauthorizedAllowlistMutation() public {
        address[] memory accounts = new address[](1);
        accounts[0] = bob;

        vm.prank(alice);
        vm.expectRevert(abi.encodeWithSelector(Unauthorized.selector, alice));
        hook.setAllowlist(accounts, true);
    }
}
