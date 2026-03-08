// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {BaseTemplateTest} from "./BaseTemplateTest.t.sol";
import {TemplateDeployers} from "./TemplateDeployers.sol";
import {StablecoinTemplateHook} from "../src/hooks/StablecoinTemplateHook.sol";
import {LongTailTemplateHook} from "../src/hooks/LongTailTemplateHook.sol";
import {StablecoinTemplateConfig} from "../src/framework/TemplateTypes.sol";
import {InvalidConfig} from "../src/framework/TemplateErrors.sol";

contract StablecoinFuzzInvariantsTest is BaseTemplateTest, TemplateDeployers {
    StablecoinTemplateHook internal hook;

    function setUp() public {
        _bootstrapCore();
        (hook,) = deployStablecoin(IPoolManager(address(manager)), address(this));
        _initializePool(IHooks(address(hook)), 300_000 ether);
        _mintAndApprove(alice, STARTING_BALANCE);

        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        cfg.base.maxTradeSize = 20_000 ether;
        hook.scheduleTemplateConfigUpdate(cfg);
        hook.applyTemplateConfigUpdate(cfg);
    }

    function testFuzz_GuardsNeverAllowForbiddenTrade(uint256 amount) public {
        amount = bound(amount, 20_001 ether, 500_000 ether);

        vm.expectRevert();
        _swapExactIn(alice, amount, true, bytes(""));
    }

    function testFuzz_ValidTradeDoesNotUnexpectedlyRevert(uint256 amount) public {
        amount = bound(amount, 1 ether, 20_000 ether);
        _swapExactIn(alice, amount, true, bytes(""));

        (,,,,, uint256 cumulativeVolume) = hook.guardState();
        assertGt(cumulativeVolume, 0);
    }

    function testFuzz_ConfigValidationInvariants(uint24 normalFee, uint24 stressFee, uint24 extremeFee) public {
        normalFee = uint24(bound(normalFee, 1, 999_999));
        stressFee = uint24(bound(stressFee, 1, 999_999));
        extremeFee = uint24(bound(extremeFee, 1, 999_999));

        vm.assume(!(normalFee <= stressFee && stressFee <= extremeFee));

        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        cfg.normalFee = normalFee;
        cfg.stressFee = stressFee;
        cfg.extremeFee = extremeFee;

        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("STABLE_FEE_ORDER")));
        hook.scheduleTemplateConfigUpdate(cfg);
    }
}

contract LongTailFuzzStateTransitionTest is BaseTemplateTest, TemplateDeployers {
    LongTailTemplateHook internal hook;

    function setUp() public {
        _bootstrapCore();
        (hook,) = deployLongTail(IPoolManager(address(manager)), address(this));
        _initializePool(IHooks(address(hook)), 300_000 ether);
        _mintAndApprove(alice, STARTING_BALANCE);
    }

    function testFuzz_ModeTransitionDoesNotRegress(uint256 warpSeconds) public {
        warpSeconds = bound(warpSeconds, 1, 3 days);

        vm.warp(block.timestamp + warpSeconds);
        bool zeroForOne = warpSeconds % 2 == 0;
        _swapExactIn(alice, 100 ether, zeroForOne, bytes(""));

        bool transitioned = !hook.launchMode();
        if (transitioned) {
            vm.warp(block.timestamp + 1 days);
            _swapExactIn(alice, 100 ether, !zeroForOne, bytes(""));
            assertFalse(hook.launchMode());
        }
    }
}
