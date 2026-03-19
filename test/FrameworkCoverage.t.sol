// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {PoolManager} from "@uniswap/v4-core/src/PoolManager.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {BaseHook} from "@uniswap/v4-periphery/src/utils/BaseHook.sol";
import {BaseTemplateHook} from "../src/framework/BaseTemplateHook.sol";
import {TemplateGuards} from "../src/framework/TemplateGuards.sol";
import {BaseTemplateConfig, GuardState} from "../src/framework/TemplateTypes.sol";
import {Unauthorized, InvalidConfig, GuardViolation} from "../src/framework/TemplateErrors.sol";
import {TemplateDeployers} from "./TemplateDeployers.sol";
import {BaseTemplateTest} from "./BaseTemplateTest.t.sol";

contract BaseTemplateHookHarness is BaseTemplateHook {
    constructor(IPoolManager _poolManager, address _admin, BaseTemplateConfig memory _baseConfig)
        BaseTemplateHook(_poolManager, _admin, _baseConfig)
    {}

    function validateHookAddress(BaseHook) internal pure override {}

    function triggerReentrant(bool recurse) external nonReentrantHook {
        if (recurse) {
            this.triggerReentrant(false);
        }
    }

    function validateBaseConfig(BaseTemplateConfig memory cfg) external pure {
        _validateBaseConfig(cfg);
    }

    function callValidateHookAddress() external pure {
        validateHookAddress(BaseHook(address(0)));
    }

    function _beforeSwap(address, PoolKey calldata, SwapParams calldata, bytes calldata)
        internal
        pure
        override
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, 0);
    }

    function _afterSwap(address, PoolKey calldata, SwapParams calldata, BalanceDelta, bytes calldata)
        internal
        pure
        override
        returns (bytes4, int128)
    {
        return (this.afterSwap.selector, 0);
    }

    function _templateId() internal pure override returns (bytes32) {
        return keccak256("HOOK_TEMPLATE_HARNESS");
    }
}

contract TemplateGuardsHarness {
    GuardState internal state;

    function enforceRateLimit(uint32 rateLimitWindow, uint16 maxSwapsPerWindow) external {
        TemplateGuards.enforceRateLimit(state, rateLimitWindow, maxSwapsPerWindow, bytes32("RL"), _revert);
    }

    function enforceCooldown(uint32 cooldownSeconds) external {
        TemplateGuards.enforceCooldown(state, cooldownSeconds, bytes32("CD"), _revert);
    }

    function enforceMaxTradeSize(uint256 maxTradeSize, uint256 tradeSize) external pure {
        TemplateGuards.enforceMaxTradeSize(maxTradeSize, tradeSize, bytes32("MT"), _revert);
    }

    function inSession(uint32 startSeconds, uint32 endSeconds) external view returns (bool) {
        return TemplateGuards.inSession(startSeconds, endSeconds);
    }

    function setLastSwapTimestamp(uint64 ts) external {
        state.lastSwapTimestamp = ts;
    }

    function _revert(bytes32 guardCode) internal pure {
        revert GuardViolation(guardCode);
    }
}

contract FrameworkCoverageTest is Test, TemplateDeployers {
    PoolManager internal manager;
    BaseTemplateHookHarness internal baseHarness;
    TemplateGuardsHarness internal guardsHarness;

    function setUp() public {
        manager = new PoolManager(address(this));
        baseHarness = new BaseTemplateHookHarness(IPoolManager(address(manager)), address(this), defaultBaseConfig());
        guardsHarness = new TemplateGuardsHarness();
    }

    function test_BaseTemplateHook_InvalidAdminConstructorReverts() public {
        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("ADMIN")));
        new BaseTemplateHookHarness(IPoolManager(address(manager)), address(0), defaultBaseConfig());
    }

    function test_BaseTemplateHook_AdminGuardsAndReentrancy() public {
        vm.prank(address(0xBEEF));
        vm.expectRevert(abi.encodeWithSelector(Unauthorized.selector, address(0xBEEF)));
        baseHarness.setAdmin(address(0xCAFE));

        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("ADMIN")));
        baseHarness.setAdmin(address(0));

        baseHarness.triggerReentrant(false);

        vm.expectRevert(abi.encodeWithSelector(GuardViolation.selector, bytes32("GUARD_REENTRANCY")));
        baseHarness.triggerReentrant(true);
    }

    function test_BaseTemplateHook_BaseConfigValidationBranches() public {
        BaseTemplateConfig memory cfg = defaultBaseConfig();
        cfg.maxTradeSize = 0;
        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("MAX_TRADE")));
        baseHarness.validateBaseConfig(cfg);

        cfg = defaultBaseConfig();
        cfg.rateLimitWindow = 0;
        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("RATE_WINDOW")));
        baseHarness.validateBaseConfig(cfg);

        cfg = defaultBaseConfig();
        cfg.maxSwapsPerWindow = 0;
        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("MAX_SWAPS")));
        baseHarness.validateBaseConfig(cfg);

        cfg = defaultBaseConfig();
        cfg.configUpdateDelay = 7 days + 1;
        vm.expectRevert(abi.encodeWithSelector(InvalidConfig.selector, bytes32("CONFIG_DELAY")));
        baseHarness.validateBaseConfig(cfg);
    }

    function test_BaseTemplateHook_VirtualPathsAreReachable() public {
        assertEq(baseHarness.templateId(), keccak256("HOOK_TEMPLATE_HARNESS"));
        baseHarness.callValidateHookAddress();

        PoolKey memory key;
        SwapParams memory params = SwapParams({zeroForOne: true, amountSpecified: -int256(1), sqrtPriceLimitX96: 1});

        vm.prank(address(manager));
        baseHarness.beforeSwap(address(this), key, params, bytes(""));

        vm.prank(address(manager));
        baseHarness.afterSwap(address(this), key, params, BalanceDelta.wrap(0), bytes(""));
    }

    function test_TemplateGuards_EarlyReturnAndBranchCoverage() public {
        guardsHarness.enforceRateLimit(0, 1);
        guardsHarness.enforceRateLimit(1, 0);

        guardsHarness.enforceMaxTradeSize(0, type(uint256).max);
        vm.expectRevert(abi.encodeWithSelector(GuardViolation.selector, bytes32("MT")));
        guardsHarness.enforceMaxTradeSize(1, 2);

        assertTrue(guardsHarness.inSession(42, 42));

        guardsHarness.setLastSwapTimestamp(uint64(block.timestamp));
        guardsHarness.enforceCooldown(0);
    }
}

contract BaseTemplateBootstrapCoverageTest is BaseTemplateTest {
    function test_ForceBootstrapSwapHitsBranch() public {
        _setForceBootstrapSwap(true);
        _bootstrapCore();
        assertTrue(lastBootstrapSwapped);
    }
}
