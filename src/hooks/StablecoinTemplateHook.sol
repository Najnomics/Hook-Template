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
import {GuardState, StablecoinTemplateConfig} from "../framework/TemplateTypes.sol";
import {InvalidConfig} from "../framework/TemplateErrors.sol";

contract StablecoinTemplateHook is BaseTemplateHook {
    using LPFeeLibrary for uint24;

    bytes32 public constant TEMPLATE_ID = keccak256("HOOK_TEMPLATE_STABLECOIN");

    bytes32 private constant FIELD_FEE_ORDER = "STABLE_FEE_ORDER";
    bytes32 private constant FIELD_DEV_ORDER = "STABLE_DEV_ORDER";
    bytes32 private constant FIELD_VOL_THRESHOLD = "STABLE_VOL_THRESHOLD";

    bytes32 private constant GUARD_STABLE_CIRCUIT = "STABLE_CIRCUIT_BREAKER";
    bytes32 private constant GUARD_STABLE_VOLATILITY = "STABLE_VOLATILITY_SPIKE";
    bytes32 private constant GUARD_STABLE_DEPEG = "STABLE_DEPEG_WARNING";

    StablecoinTemplateConfig public config;
    GuardState public guardState;

    uint24 public lastAppliedFee;
    int24 public lastObservedTick;
    uint64 public circuitBreakerUntil;

    constructor(IPoolManager _poolManager, address _admin, StablecoinTemplateConfig memory _config)
        BaseTemplateHook(_poolManager, _admin, _config.base)
    {
        _validateTemplateConfig(_config);
        config = _config;
        lastAppliedFee = _config.normalFee;
    }

    function scheduleTemplateConfigUpdate(StablecoinTemplateConfig calldata newConfig) external onlyAdmin {
        _validateTemplateConfig(newConfig);
        _stageConfigHash(keccak256(abi.encode(newConfig)));
    }

    function applyTemplateConfigUpdate(StablecoinTemplateConfig calldata newConfig) external onlyAdmin {
        _validateTemplateConfig(newConfig);
        bytes32 configHash = keccak256(abi.encode(newConfig));
        _consumeStagedConfigHash(configHash);

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

        int24 currentTick = _readCurrentTick(poolId);
        uint256 deviation = _absTick(currentTick);

        uint24 nextFee = _feeForDeviation(deviation);

        if (lastObservedTick != 0 && _tickDistance(currentTick, lastObservedTick) >= config.volatilityThreshold) {
            if (nextFee < config.stressFee) {
                nextFee = config.stressFee;
            }
            _emitGuard(poolId, GUARD_STABLE_VOLATILITY, int256(uint256(config.volatilityThreshold)));
        }

        if (deviation >= config.stressDeviation) {
            _emitGuard(poolId, GUARD_STABLE_DEPEG, int256(deviation));
        }

        if (config.circuitBreakerEnabled && deviation >= config.circuitBreakerDeviation) {
            if (block.timestamp < circuitBreakerUntil) {
                _revertGuard(GUARD_STABLE_CIRCUIT);
            }
            circuitBreakerUntil = uint64(block.timestamp + baseConfig.cooldownSeconds);
            _emitGuard(poolId, GUARD_STABLE_CIRCUIT, int256(deviation));
            nextFee = config.extremeFee;
        }

        if (nextFee != lastAppliedFee) {
            _emitFeeUpdate(poolId, lastAppliedFee, nextFee);
            lastAppliedFee = nextFee;
        }

        lastObservedTick = currentTick;

        // `beforeSwap` returns an LP fee override for dynamic-fee pools.
        return (this.beforeSwap.selector, BeforeSwapDeltaLibrary.ZERO_DELTA, _lpFeeOverride(nextFee));
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

    function _validateTemplateConfig(StablecoinTemplateConfig memory cfg) private pure {
        _validateBaseConfig(cfg.base);

        if (cfg.normalFee > cfg.stressFee || cfg.stressFee > cfg.extremeFee) {
            revert InvalidConfig(FIELD_FEE_ORDER);
        }

        if (
            cfg.stressDeviation > cfg.extremeDeviation || cfg.extremeDeviation > cfg.circuitBreakerDeviation
                || cfg.stressDeviation == 0
        ) {
            revert InvalidConfig(FIELD_DEV_ORDER);
        }

        if (cfg.volatilityThreshold == 0) {
            revert InvalidConfig(FIELD_VOL_THRESHOLD);
        }

        cfg.normalFee.validate();
        cfg.stressFee.validate();
        cfg.extremeFee.validate();
    }

    function _feeForDeviation(uint256 deviation) private view returns (uint24) {
        if (deviation >= config.extremeDeviation) {
            return config.extremeFee;
        }
        if (deviation >= config.stressDeviation) {
            return config.stressFee;
        }
        return config.normalFee;
    }

    function _absTick(int24 tick) private pure returns (uint256) {
        return uint256(uint24(tick >= 0 ? tick : -tick));
    }

    function _tickDistance(int24 lhs, int24 rhs) private pure returns (uint24) {
        return uint24(lhs >= rhs ? lhs - rhs : rhs - lhs);
    }

    function _absSpecified(int256 amountSpecified) private pure returns (uint256) {
        return amountSpecified >= 0 ? uint256(amountSpecified) : uint256(-amountSpecified);
    }

    function _templateId() internal pure override returns (bytes32) {
        return TEMPLATE_ID;
    }
}
