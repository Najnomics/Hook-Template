// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId} from "@uniswap/v4-core/src/types/PoolId.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {BalanceDelta} from "@uniswap/v4-core/src/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "@uniswap/v4-core/src/types/BeforeSwapDelta.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";
import {BaseTemplateHook} from "../framework/BaseTemplateHook.sol";
import {GuardState, LongTailTemplateConfig} from "../framework/TemplateTypes.sol";
import {InvalidConfig} from "../framework/TemplateErrors.sol";

contract LongTailTemplateHook is BaseTemplateHook {
    using LPFeeLibrary for uint24;

    bytes32 public constant TEMPLATE_ID = keccak256("HOOK_TEMPLATE_LONG_TAIL");

    bytes32 private constant MODE_LAUNCH = "LAUNCH_MODE";
    bytes32 private constant MODE_NORMAL = "NORMAL_MODE";

    bytes32 private constant FIELD_FEE_ORDER = "LONGTAIL_FEE_ORDER";
    bytes32 private constant FIELD_LAUNCH_DURATION = "LONGTAIL_DURATION";
    bytes32 private constant FIELD_MAX_TRADE_PATH = "LONGTAIL_MAX_TRADE_PATH";
    bytes32 private constant FIELD_PER_BLOCK_CAP = "LONGTAIL_PER_BLOCK_CAP";
    bytes32 private constant FIELD_VOLUME_THRESHOLD = "LONGTAIL_VOLUME_THRESHOLD";

    bytes32 private constant GUARD_LONGTAIL_LAUNCH_SIZE = "LONGTAIL_LAUNCH_SIZE";
    bytes32 private constant GUARD_LONGTAIL_BLOCK_VOLUME = "LONGTAIL_BLOCK_VOLUME";

    LongTailTemplateConfig public config;
    GuardState public guardState;

    uint64 public immutable launchStart;
    bool public launchMode;
    uint24 public lastAppliedFee;

    constructor(IPoolManager _poolManager, address _admin, LongTailTemplateConfig memory _config)
        BaseTemplateHook(_poolManager, _admin, _config.base)
    {
        _validateTemplateConfig(_config);

        config = _config;
        launchStart = uint64(block.timestamp);
        launchMode = true;
        lastAppliedFee = _config.launchFee;
    }

    function scheduleTemplateConfigUpdate(LongTailTemplateConfig calldata newConfig) external onlyAdmin {
        _validateTemplateConfig(newConfig);
        _stageTemplateConfigHash(keccak256(abi.encode(newConfig)));
    }

    function applyTemplateConfigUpdate(LongTailTemplateConfig calldata newConfig) external onlyAdmin {
        _validateTemplateConfig(newConfig);
        bytes32 configHash = keccak256(abi.encode(newConfig));
        _consumeStagedTemplateConfigHash(configHash);

        config = newConfig;
        baseConfig = newConfig.base;

        emit ConfigUpdated(_templateId(), supportedPoolId, configHash, block.timestamp);
    }

    function _beforeSwap(address, PoolKey calldata key, SwapParams calldata params, bytes calldata)
        internal
        override
        nonReentrantHook
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        (PoolId poolId, uint256 tradeSize) = _sharedBeforeSwap(key, params, guardState);

        uint24 fee = config.normalFee;
        if (launchMode) {
            uint256 launchCap = _currentLaunchMaxTrade();
            if (tradeSize > launchCap) {
                _revertGuard(GUARD_LONGTAIL_LAUNCH_SIZE);
            }

            if (config.segmentedOrderFlow) {
                uint256 projectedVolume =
                    guardState.lastSwapBlock == uint64(block.number) ? guardState.blockVolume + tradeSize : tradeSize;
                if (projectedVolume > config.perBlockVolumeCap) {
                    _revertGuard(GUARD_LONGTAIL_BLOCK_VOLUME);
                }
            }

            fee = _currentLaunchFee();
        }

        if (fee != lastAppliedFee) {
            _emitFeeUpdate(poolId, lastAppliedFee, fee);
            lastAppliedFee = fee;
        }

        return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, _lpFeeOverride(fee));
    }

    function _afterSwap(address, PoolKey calldata key, SwapParams calldata params, BalanceDelta, bytes calldata)
        internal
        override
        nonReentrantHook
        returns (bytes4, int128)
    {
        PoolId poolId = _assertSupportedPool(key);
        _sharedAfterSwap(guardState, _absSpecified(params.amountSpecified));

        if (launchMode && _shouldTransitionToNormal()) {
            launchMode = false;
            _emitModeTransition(poolId, MODE_LAUNCH, MODE_NORMAL);
            if (lastAppliedFee != config.normalFee) {
                _emitFeeUpdate(poolId, lastAppliedFee, config.normalFee);
                lastAppliedFee = config.normalFee;
            }
        }

        return (this.afterSwap.selector, 0);
    }

    function _validateTemplateConfig(LongTailTemplateConfig memory cfg) private pure {
        _validateBaseConfig(cfg.base);

        if (cfg.launchFee < cfg.normalFee) revert InvalidConfig(FIELD_FEE_ORDER);
        if (cfg.launchDuration == 0) revert InvalidConfig(FIELD_LAUNCH_DURATION);
        if (cfg.initialMaxTrade == 0 || cfg.initialMaxTrade > cfg.finalMaxTrade) {
            revert InvalidConfig(FIELD_MAX_TRADE_PATH);
        }
        if (cfg.segmentedOrderFlow && cfg.perBlockVolumeCap == 0) revert InvalidConfig(FIELD_PER_BLOCK_CAP);
        if (cfg.volumeTransitionThreshold == 0) revert InvalidConfig(FIELD_VOLUME_THRESHOLD);

        cfg.launchFee.validate();
        cfg.normalFee.validate();
    }

    function _shouldTransitionToNormal() private view returns (bool) {
        bool byTime = block.timestamp >= uint256(launchStart) + config.launchDuration;
        bool byVolume = guardState.cumulativeVolume >= config.volumeTransitionThreshold;
        return byTime || byVolume;
    }

    function _currentLaunchFee() private view returns (uint24) {
        uint256 elapsed = block.timestamp > launchStart ? block.timestamp - launchStart : 0;
        if (elapsed >= config.launchDuration) return config.normalFee;

        uint24 feeDelta = config.launchFee - config.normalFee;
        uint256 decayed = (uint256(feeDelta) * elapsed) / config.launchDuration;
        return config.launchFee - uint24(decayed);
    }

    function _currentLaunchMaxTrade() private view returns (uint256) {
        uint256 elapsed = block.timestamp > launchStart ? block.timestamp - launchStart : 0;
        if (elapsed >= config.launchDuration) return config.finalMaxTrade;

        uint256 tradeDelta = config.finalMaxTrade - config.initialMaxTrade;
        uint256 growth = (tradeDelta * elapsed) / config.launchDuration;
        return config.initialMaxTrade + growth;
    }

    function _absSpecified(int256 amountSpecified) private pure returns (uint256) {
        return amountSpecified >= 0 ? uint256(amountSpecified) : uint256(-amountSpecified);
    }

    function _templateId() internal pure override returns (bytes32) {
        return TEMPLATE_ID;
    }
}
