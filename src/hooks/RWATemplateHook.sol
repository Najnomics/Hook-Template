// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";
import {TemplateGuards} from "../framework/TemplateGuards.sol";
import {BaseTemplateHook} from "../framework/BaseTemplateHook.sol";
import {GuardState, RWATemplateConfig} from "../framework/TemplateTypes.sol";
import {InvalidConfig} from "../framework/TemplateErrors.sol";

contract RWATemplateHook is BaseTemplateHook {
    using LPFeeLibrary for uint24;

    bytes32 public constant TEMPLATE_ID = keccak256("HOOK_TEMPLATE_RWA");

    bytes32 private constant FIELD_MAX_TICK_JUMP = "RWA_MAX_TICK_JUMP";
    bytes32 private constant FIELD_MAX_SLIPPAGE = "RWA_MAX_SLIPPAGE";
    bytes32 private constant FIELD_SESSION = "RWA_SESSION";

    bytes32 private constant GUARD_RWA_SESSION = "RWA_SESSION_CLOSED";
    bytes32 private constant GUARD_RWA_ALLOWLIST = "RWA_ALLOWLIST";
    bytes32 private constant GUARD_RWA_TICK_JUMP = "RWA_TICK_JUMP";
    bytes32 private constant GUARD_RWA_SLIPPAGE = "RWA_SLIPPAGE";

    RWATemplateConfig public config;
    GuardState public guardState;

    mapping(address => bool) public allowlisted;

    int24 public lastObservedTick;
    uint24 public lastAppliedFee;

    constructor(IPoolManager _poolManager, address _admin, RWATemplateConfig memory _config)
        BaseTemplateHook(_poolManager, _admin, _config.base)
    {
        _validateTemplateConfig(_config);

        config = _config;
        allowlisted[_admin] = true;
        lastAppliedFee = _config.sessionFee;
    }

    function setAllowlist(address[] calldata accounts, bool allowed) external onlyAdmin {
        uint256 len = accounts.length;
        for (uint256 i = 0; i < len; i++) {
            allowlisted[accounts[i]] = allowed;
        }
    }

    function scheduleTemplateConfigUpdate(RWATemplateConfig calldata newConfig) external onlyAdmin {
        _validateTemplateConfig(newConfig);
        _stageConfigHash(keccak256(abi.encode(newConfig)));
    }

    function applyTemplateConfigUpdate(RWATemplateConfig calldata newConfig) external onlyAdmin {
        _validateTemplateConfig(newConfig);
        bytes32 configHash = keccak256(abi.encode(newConfig));
        _consumeStagedConfigHash(configHash);

        config = newConfig;
        baseConfig = newConfig.base;

        emit ConfigUpdated(_templateId(), supportedPoolId, configHash, block.timestamp);
    }

    function _beforeSwap(address sender, PoolKey calldata key, SwapParams calldata params, bytes calldata hookData)
        internal
        override
        nonReentrantHook
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        (PoolId poolId, uint256 tradeSize) = _sharedBeforeSwap(key, params, guardState);

        if (!TemplateGuards.inSession(config.sessionOpenSeconds, config.sessionCloseSeconds)) {
            _revertGuard(GUARD_RWA_SESSION);
        }

        address actor = _extractActor(sender, hookData);
        if (config.permissionedOnly && !allowlisted[actor]) {
            _revertGuard(GUARD_RWA_ALLOWLIST);
        }

        int24 currentTick = _readCurrentTick(poolId);
        if (lastObservedTick != 0 && _tickDistance(currentTick, lastObservedTick) > config.maxTickJump) {
            _revertGuard(GUARD_RWA_TICK_JUMP);
        }

        // Lightweight slippage guardrail: cap notional aggressiveness relative to configured max trade.
        uint256 impliedBps = (tradeSize * 10_000) / baseConfig.maxTradeSize;
        if (impliedBps > config.maxSlippageBps) {
            _revertGuard(GUARD_RWA_SLIPPAGE);
        }

        if (lastAppliedFee != config.sessionFee) {
            _emitFeeUpdate(poolId, lastAppliedFee, config.sessionFee);
            lastAppliedFee = config.sessionFee;
        }

        lastObservedTick = currentTick;

        return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, _lpFeeOverride(config.sessionFee));
    }

    function _afterSwap(address, PoolKey calldata key, SwapParams calldata params, BalanceDelta, bytes calldata)
        internal
        override
        nonReentrantHook
        returns (bytes4, int128)
    {
        _assertSupportedPool(key);
        _sharedAfterSwap(guardState, _absSpecified(params.amountSpecified));
        return (this.afterSwap.selector, 0);
    }

    function _validateTemplateConfig(RWATemplateConfig memory cfg) private pure {
        _validateBaseConfig(cfg.base);

        if (cfg.maxTickJump == 0) revert InvalidConfig(FIELD_MAX_TICK_JUMP);
        if (cfg.maxSlippageBps == 0 || cfg.maxSlippageBps > 10_000) revert InvalidConfig(FIELD_MAX_SLIPPAGE);
        if (cfg.sessionOpenSeconds >= 1 days || cfg.sessionCloseSeconds >= 1 days) revert InvalidConfig(FIELD_SESSION);

        cfg.sessionFee.validate();
    }

    function _tickDistance(int24 lhs, int24 rhs) private pure returns (uint256) {
        int24 delta = lhs >= rhs ? lhs - rhs : rhs - lhs;
        return uint256(uint24(delta));
    }

    function _absSpecified(int256 amountSpecified) private pure returns (uint256) {
        return amountSpecified >= 0 ? uint256(amountSpecified) : uint256(-amountSpecified);
    }

    function _templateId() internal pure override returns (bytes32) {
        return TEMPLATE_ID;
    }
}
