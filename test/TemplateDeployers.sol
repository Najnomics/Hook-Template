// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {HookMiner} from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import {
    BaseTemplateConfig,
    StablecoinTemplateConfig,
    RWATemplateConfig,
    LongTailTemplateConfig
} from "../src/framework/TemplateTypes.sol";
import {StablecoinTemplateHook} from "../src/hooks/StablecoinTemplateHook.sol";
import {RWATemplateHook} from "../src/hooks/RWATemplateHook.sol";
import {LongTailTemplateHook} from "../src/hooks/LongTailTemplateHook.sol";

contract TemplateDeployers {
    uint160 internal constant TEMPLATE_FLAGS =
        Hooks.AFTER_INITIALIZE_FLAG | Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG;

    function defaultBaseConfig() internal pure returns (BaseTemplateConfig memory) {
        return BaseTemplateConfig({
            maxTradeSize: 250_000 ether,
            rateLimitWindow: 120,
            maxSwapsPerWindow: 100,
            cooldownSeconds: 0,
            configUpdateDelay: 0
        });
    }

    function defaultStablecoinConfig() internal pure returns (StablecoinTemplateConfig memory cfg) {
        cfg = StablecoinTemplateConfig({
            base: defaultBaseConfig(),
            normalFee: 500,
            stressFee: 1_500,
            extremeFee: 3_000,
            stressDeviation: 20,
            extremeDeviation: 50,
            circuitBreakerDeviation: 120,
            volatilityThreshold: 25,
            circuitBreakerEnabled: true
        });
    }

    function defaultRWAConfig() internal pure returns (RWATemplateConfig memory cfg) {
        cfg = RWATemplateConfig({
            base: defaultBaseConfig(),
            sessionFee: 2_500,
            maxTickJump: 80,
            maxSlippageBps: 7_500,
            sessionOpenSeconds: 0,
            sessionCloseSeconds: 1 days - 1,
            permissionedOnly: true
        });
    }

    function defaultLongTailConfig() internal pure returns (LongTailTemplateConfig memory cfg) {
        cfg = LongTailTemplateConfig({
            base: defaultBaseConfig(),
            launchFee: 8_000,
            normalFee: 3_000,
            launchDuration: 12 hours,
            initialMaxTrade: 10_000 ether,
            finalMaxTrade: 250_000 ether,
            volumeTransitionThreshold: 1_000_000 ether,
            perBlockVolumeCap: 50_000 ether,
            segmentedOrderFlow: true
        });
    }

    function deployStablecoin(IPoolManager manager, address admin)
        internal
        returns (StablecoinTemplateHook hook, bytes32 salt)
    {
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        bytes memory constructorArgs = abi.encode(manager, admin, cfg);
        (, salt) =
            HookMiner.find(address(this), TEMPLATE_FLAGS, type(StablecoinTemplateHook).creationCode, constructorArgs);
        hook = new StablecoinTemplateHook{salt: salt}(manager, admin, cfg);
    }

    function deployRWA(IPoolManager manager, address admin) internal returns (RWATemplateHook hook, bytes32 salt) {
        RWATemplateConfig memory cfg = defaultRWAConfig();
        bytes memory constructorArgs = abi.encode(manager, admin, cfg);
        (, salt) = HookMiner.find(address(this), TEMPLATE_FLAGS, type(RWATemplateHook).creationCode, constructorArgs);
        hook = new RWATemplateHook{salt: salt}(manager, admin, cfg);
    }

    function deployLongTail(IPoolManager manager, address admin)
        internal
        returns (LongTailTemplateHook hook, bytes32 salt)
    {
        LongTailTemplateConfig memory cfg = defaultLongTailConfig();
        bytes memory constructorArgs = abi.encode(manager, admin, cfg);
        (, salt) =
            HookMiner.find(address(this), TEMPLATE_FLAGS, type(LongTailTemplateHook).creationCode, constructorArgs);
        hook = new LongTailTemplateHook{salt: salt}(manager, admin, cfg);
    }
}
