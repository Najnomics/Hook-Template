// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {Hooks} from "@uniswap/v4-core/src/libraries/Hooks.sol";
import {HookMiner} from "@uniswap/v4-periphery/src/utils/HookMiner.sol";
import {TemplateEvents} from "../framework/TemplateEvents.sol";
import {StablecoinTemplateConfig, RWATemplateConfig, LongTailTemplateConfig} from "../framework/TemplateTypes.sol";
import {StablecoinTemplateHook} from "../hooks/StablecoinTemplateHook.sol";
import {RWATemplateHook} from "../hooks/RWATemplateHook.sol";
import {LongTailTemplateHook} from "../hooks/LongTailTemplateHook.sol";

contract TemplateFactory is TemplateEvents {
    bytes32 public constant STABLE_TEMPLATE_ID = keccak256("HOOK_TEMPLATE_STABLECOIN");
    bytes32 public constant RWA_TEMPLATE_ID = keccak256("HOOK_TEMPLATE_RWA");
    bytes32 public constant LONGTAIL_TEMPLATE_ID = keccak256("HOOK_TEMPLATE_LONG_TAIL");

    uint160 internal constant TEMPLATE_FLAGS =
        Hooks.AFTER_INITIALIZE_FLAG | Hooks.BEFORE_SWAP_FLAG | Hooks.AFTER_SWAP_FLAG;

    function mineStablecoinSalt(IPoolManager manager, address admin, StablecoinTemplateConfig calldata config)
        external
        view
        returns (address hookAddress, bytes32 salt)
    {
        return HookMiner.find(
            address(this), TEMPLATE_FLAGS, type(StablecoinTemplateHook).creationCode, abi.encode(manager, admin, config)
        );
    }

    function mineRWASalt(IPoolManager manager, address admin, RWATemplateConfig calldata config)
        external
        view
        returns (address hookAddress, bytes32 salt)
    {
        return HookMiner.find(
            address(this), TEMPLATE_FLAGS, type(RWATemplateHook).creationCode, abi.encode(manager, admin, config)
        );
    }

    function mineLongTailSalt(IPoolManager manager, address admin, LongTailTemplateConfig calldata config)
        external
        view
        returns (address hookAddress, bytes32 salt)
    {
        return HookMiner.find(
            address(this), TEMPLATE_FLAGS, type(LongTailTemplateHook).creationCode, abi.encode(manager, admin, config)
        );
    }

    function deployStablecoin(IPoolManager manager, StablecoinTemplateConfig calldata config, bytes32 salt)
        external
        returns (address hook)
    {
        hook = address(new StablecoinTemplateHook{salt: salt}(manager, msg.sender, config));
        emit TemplateDeployed(STABLE_TEMPLATE_ID, hook, msg.sender, keccak256(abi.encode(config)));
    }

    function deployRWA(IPoolManager manager, RWATemplateConfig calldata config, bytes32 salt)
        external
        returns (address hook)
    {
        hook = address(new RWATemplateHook{salt: salt}(manager, msg.sender, config));
        emit TemplateDeployed(RWA_TEMPLATE_ID, hook, msg.sender, keccak256(abi.encode(config)));
    }

    function deployLongTail(IPoolManager manager, LongTailTemplateConfig calldata config, bytes32 salt)
        external
        returns (address hook)
    {
        hook = address(new LongTailTemplateHook{salt: salt}(manager, msg.sender, config));
        emit TemplateDeployed(LONGTAIL_TEMPLATE_ID, hook, msg.sender, keccak256(abi.encode(config)));
    }
}
