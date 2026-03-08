// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IHooks} from "@uniswap/v4-core/src/interfaces/IHooks.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "@uniswap/v4-core/src/types/PoolKey.sol";
import {TemplateDemoBase} from "./base/TemplateDemoBase.s.sol";
import {RWATemplateHook} from "../src/hooks/RWATemplateHook.sol";
import {BaseTemplateConfig, RWATemplateConfig} from "../src/framework/TemplateTypes.sol";

contract DemoRWAScript is TemplateDemoBase {
    function run() external {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        address trader = vm.addr(privateKey);

        vm.startBroadcast(privateKey);

        DemoStack memory stack = _deployCore(trader);

        RWATemplateConfig memory cfg = RWATemplateConfig({
            base: BaseTemplateConfig({
                maxTradeSize: 150_000 ether,
                rateLimitWindow: 600,
                maxSwapsPerWindow: 30,
                cooldownSeconds: 30,
                configUpdateDelay: 0
            }),
            sessionFee: 2_500,
            maxTickJump: 120,
            maxSlippageBps: 8_000,
            sessionOpenSeconds: 0,
            sessionCloseSeconds: 1 days - 1,
            permissionedOnly: true
        });

        bytes memory args = abi.encode(IPoolManager(address(stack.manager)), trader, cfg);
        bytes32 salt = _mineSalt(type(RWATemplateHook).creationCode, args);
        RWATemplateHook hook = new RWATemplateHook{salt: salt}(IPoolManager(address(stack.manager)), trader, cfg);

        address[] memory allowlist = new address[](1);
        allowlist[0] = address(stack.swapRouter);
        hook.setAllowlist(allowlist, true);

        PoolKey memory key = _initializePool(stack, IHooks(address(hook)));

        _swap(stack.swapRouter, key, true, 3_000 ether, bytes(""));
        _swap(stack.swapRouter, key, false, 2_000 ether, bytes(""));
        _swap(stack.swapRouter, key, true, 1_500 ether, bytes(""));

        vm.stopBroadcast();
        _logCore(stack, address(hook));
    }
}
