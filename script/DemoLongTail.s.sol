// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {TemplateDemoBase} from "./base/TemplateDemoBase.s.sol";
import {LongTailTemplateHook} from "../src/hooks/LongTailTemplateHook.sol";
import {BaseTemplateConfig, LongTailTemplateConfig} from "../src/framework/TemplateTypes.sol";

contract DemoLongTailScript is TemplateDemoBase {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address trader = vm.addr(privateKey);

        vm.startBroadcast(privateKey);

        DemoStack memory stack = _deployCore(trader);

        LongTailTemplateConfig memory cfg = LongTailTemplateConfig({
            base: BaseTemplateConfig({
                maxTradeSize: 300_000 ether,
                rateLimitWindow: 120,
                maxSwapsPerWindow: 100,
                cooldownSeconds: 0,
                configUpdateDelay: 0
            }),
            launchFee: 8_000,
            normalFee: 2_500,
            launchDuration: 2 hours,
            initialMaxTrade: 20_000 ether,
            finalMaxTrade: 300_000 ether,
            volumeTransitionThreshold: 12_000 ether,
            perBlockVolumeCap: 40_000 ether,
            segmentedOrderFlow: true
        });

        bytes memory args = abi.encode(stack.manager, trader, cfg);
        bytes32 salt = _mineSalt(type(LongTailTemplateHook).creationCode, args);
        LongTailTemplateHook hook =
            new LongTailTemplateHook{salt: salt}(stack.manager, trader, cfg);

        PoolKey memory key = _initializePool(stack, IHooks(address(hook)));

        _swap(stack.swapRouter, key, true, 10_000 ether, bytes(""));
        _swap(stack.swapRouter, key, false, 5_000 ether, bytes(""));
        _swap(stack.swapRouter, key, true, 35_000 ether, bytes(""));

        vm.stopBroadcast();
        _logCore(stack, address(hook));
    }
}
