// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {TemplateDemoBase} from "./base/TemplateDemoBase.s.sol";
import {StablecoinTemplateHook} from "../src/hooks/StablecoinTemplateHook.sol";
import {BaseTemplateConfig, StablecoinTemplateConfig} from "../src/framework/TemplateTypes.sol";

contract DemoStablecoinScript is TemplateDemoBase {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address trader = vm.addr(privateKey);

        vm.startBroadcast(privateKey);

        DemoStack memory stack = _deployCore(trader);

        StablecoinTemplateConfig memory cfg = StablecoinTemplateConfig({
            base: BaseTemplateConfig({
                maxTradeSize: 300_000 ether,
                rateLimitWindow: 120,
                maxSwapsPerWindow: 100,
                cooldownSeconds: 60,
                configUpdateDelay: 0
            }),
            normalFee: 500,
            stressFee: 2_000,
            extremeFee: 4_000,
            stressDeviation: 15,
            extremeDeviation: 40,
            circuitBreakerDeviation: 100,
            volatilityThreshold: 20,
            circuitBreakerEnabled: true
        });

        bytes memory args = abi.encode(IPoolManager(address(stack.manager)), trader, cfg);
        bytes32 salt = _mineSalt(type(StablecoinTemplateHook).creationCode, args);
        StablecoinTemplateHook hook =
            new StablecoinTemplateHook{salt: salt}(IPoolManager(address(stack.manager)), trader, cfg);

        PoolKey memory key = _initializePool(stack, IHooks(address(hook)));

        _swap(stack.swapRouter, key, true, 5_000 ether, bytes(""));
        _swap(stack.swapRouter, key, true, 25_000 ether, bytes(""));
        _swap(stack.swapRouter, key, false, 10_000 ether, bytes(""));

        vm.stopBroadcast();
        _logCore(stack, address(hook));
    }
}
