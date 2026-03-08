// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {BaseHook} from "@uniswap/v4-periphery/src/utils/BaseHook.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {LPFeeLibrary} from "@uniswap/v4-core/src/libraries/LPFeeLibrary.sol";
import {StateLibrary} from "@uniswap/v4-core/src/libraries/StateLibrary.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "@uniswap/v4-core/src/types/PoolId.sol";
import {SwapParams} from "@uniswap/v4-core/src/types/PoolOperation.sol";
import {TemplateEvents} from "./TemplateEvents.sol";
import {TemplateGuards} from "./TemplateGuards.sol";
import {BaseTemplateConfig, GuardState} from "./TemplateTypes.sol";
import {Unauthorized, InvalidConfig, GuardViolation, UnsupportedPool} from "./TemplateErrors.sol";

abstract contract BaseTemplateHook is BaseHook, TemplateEvents {
    using PoolIdLibrary for PoolKey;
    using StateLibrary for IPoolManager;

    bytes32 internal constant FIELD_ADMIN = "ADMIN";
    bytes32 internal constant FIELD_MAX_TRADE = "MAX_TRADE";
    bytes32 internal constant FIELD_RATE_WINDOW = "RATE_WINDOW";
    bytes32 internal constant FIELD_MAX_SWAPS = "MAX_SWAPS";
    bytes32 internal constant FIELD_CONFIG_DELAY = "CONFIG_DELAY";

    bytes32 internal constant GUARD_MAX_TRADE = "GUARD_MAX_TRADE";
    bytes32 internal constant GUARD_RATE_LIMIT = "GUARD_RATE_LIMIT";
    bytes32 internal constant GUARD_COOLDOWN = "GUARD_COOLDOWN";
    bytes32 internal constant GUARD_REENTRANCY = "GUARD_REENTRANCY";

    uint32 internal constant MAX_CONFIG_DELAY = 7 days;

    address public admin;
    BaseTemplateConfig public baseConfig;

    bytes32 public supportedPoolId;

    bytes32 public pendingConfigHash;
    uint64 public pendingConfigEta;

    uint256 private _hookLock;

    modifier onlyAdmin() {
        if (msg.sender != admin) revert Unauthorized(msg.sender);
        _;
    }

    modifier nonReentrantHook() {
        if (_hookLock == 1) _revertGuard(GUARD_REENTRANCY);
        _hookLock = 1;
        _;
        _hookLock = 0;
    }

    constructor(IPoolManager _poolManager, address _admin, BaseTemplateConfig memory _baseConfig)
        BaseHook(_poolManager)
    {
        if (_admin == address(0)) revert InvalidConfig(FIELD_ADMIN);
        _validateBaseConfig(_baseConfig);

        admin = _admin;
        baseConfig = _baseConfig;
    }

    function templateId() external pure returns (bytes32) {
        return _templateId();
    }

    function setAdmin(address newAdmin) external onlyAdmin {
        if (newAdmin == address(0)) revert InvalidConfig(FIELD_ADMIN);
        admin = newAdmin;
    }

    function scheduleBaseConfigUpdate(BaseTemplateConfig calldata newConfig) external onlyAdmin {
        _validateBaseConfig(newConfig);
        bytes32 configHash = keccak256(abi.encode(newConfig));
        _stageConfigHash(configHash);
    }

    function applyBaseConfigUpdate(BaseTemplateConfig calldata newConfig) external onlyAdmin {
        _validateBaseConfig(newConfig);
        bytes32 configHash = keccak256(abi.encode(newConfig));
        _consumeStagedConfigHash(configHash);
        baseConfig = newConfig;
        emit ConfigUpdated(_templateId(), supportedPoolId, configHash, block.timestamp);
    }

    function cancelStagedConfig() external onlyAdmin {
        delete pendingConfigHash;
        delete pendingConfigEta;
    }

    function getHookPermissions() public pure virtual override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: true,
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeSwap: true,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false,
            beforeSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    function _afterInitialize(address, PoolKey calldata key, uint160, int24)
        internal
        virtual
        override
        returns (bytes4)
    {
        bytes32 poolId = PoolId.unwrap(key.toId());
        if (supportedPoolId == bytes32(0)) {
            supportedPoolId = poolId;
        } else if (supportedPoolId != poolId) {
            revert UnsupportedPool(poolId);
        }

        return BaseHook.afterInitialize.selector;
    }

    function _validateBaseConfig(BaseTemplateConfig memory cfg) internal pure {
        if (cfg.maxTradeSize == 0) revert InvalidConfig(FIELD_MAX_TRADE);
        if (cfg.rateLimitWindow == 0) revert InvalidConfig(FIELD_RATE_WINDOW);
        if (cfg.maxSwapsPerWindow == 0) revert InvalidConfig(FIELD_MAX_SWAPS);
        if (cfg.configUpdateDelay > MAX_CONFIG_DELAY) revert InvalidConfig(FIELD_CONFIG_DELAY);
    }

    function _assertSupportedPool(PoolKey calldata key) internal view returns (PoolId poolId) {
        poolId = key.toId();
        bytes32 poolIdRaw = PoolId.unwrap(poolId);
        if (supportedPoolId == bytes32(0) || supportedPoolId != poolIdRaw) {
            revert UnsupportedPool(poolIdRaw);
        }
    }

    function _sharedBeforeSwap(PoolKey calldata key, SwapParams calldata params, GuardState storage state)
        internal
        returns (PoolId poolId, uint256 tradeSize)
    {
        poolId = _assertSupportedPool(key);
        tradeSize = TemplateGuards.abs(params.amountSpecified);

        TemplateGuards.enforceMaxTradeSize(baseConfig.maxTradeSize, tradeSize, GUARD_MAX_TRADE, _revertGuard);
        TemplateGuards.enforceRateLimit(
            state, baseConfig.rateLimitWindow, baseConfig.maxSwapsPerWindow, GUARD_RATE_LIMIT, _revertGuard
        );
        TemplateGuards.enforceCooldown(state, baseConfig.cooldownSeconds, GUARD_COOLDOWN, _revertGuard);
    }

    function _sharedAfterSwap(GuardState storage state, uint256 tradeSize) internal {
        TemplateGuards.updateAfterSwap(state, tradeSize);
    }

    function _extractActor(address sender, bytes calldata hookData) internal pure returns (address actor) {
        actor = sender;
        if (hookData.length >= 20) {
            assembly ("memory-safe") {
                actor := shr(96, calldataload(hookData.offset))
            }
        }
    }

    function _readCurrentTick(PoolId poolId) internal view returns (int24 tick) {
        (, tick,,) = poolManager.getSlot0(poolId);
    }

    function _lpFeeOverride(uint24 fee) internal pure returns (uint24) {
        LPFeeLibrary.validate(fee);
        return fee | LPFeeLibrary.OVERRIDE_FEE_FLAG;
    }

    function _emitFeeUpdate(PoolId poolId, uint24 oldFee, uint24 newFee) internal {
        emit FeeUpdated(_templateId(), PoolId.unwrap(poolId), oldFee, newFee);
    }

    function _emitModeTransition(PoolId poolId, bytes32 oldMode, bytes32 newMode) internal {
        emit ModeTransitioned(_templateId(), PoolId.unwrap(poolId), oldMode, newMode);
    }

    function _emitGuard(PoolId poolId, bytes32 guard, int256 contextValue) internal {
        emit GuardTriggered(_templateId(), PoolId.unwrap(poolId), guard, contextValue);
    }

    function _stageConfigHash(bytes32 configHash) internal {
        pendingConfigHash = configHash;
        pendingConfigEta = uint64(block.timestamp + baseConfig.configUpdateDelay);
    }

    function _consumeStagedConfigHash(bytes32 configHash) internal {
        if (pendingConfigHash == bytes32(0) || pendingConfigHash != configHash) {
            revert GuardViolation("CONFIG_HASH_MISMATCH");
        }
        if (block.timestamp < pendingConfigEta) {
            revert GuardViolation("CONFIG_DELAY_ACTIVE");
        }

        delete pendingConfigHash;
        delete pendingConfigEta;
    }

    function _revertGuard(bytes32 guardCode) internal pure {
        revert GuardViolation(guardCode);
    }

    function _templateId() internal pure virtual returns (bytes32);
}
