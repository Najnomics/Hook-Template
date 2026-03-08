// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {PoolManager} from "@uniswap/v4-core/src/PoolManager.sol";
import {TemplateFactory} from "../src/factory/TemplateFactory.sol";
import {TemplateDeployers} from "./TemplateDeployers.sol";
import {StablecoinTemplateConfig, RWATemplateConfig, LongTailTemplateConfig} from "../src/framework/TemplateTypes.sol";

contract TemplateFactoryTest is Test, TemplateDeployers {
    TemplateFactory internal factory;
    PoolManager internal manager;

    function setUp() public {
        factory = new TemplateFactory();
        manager = new PoolManager(address(this));
    }

    function test_MineAndDeployStablecoinHook() public {
        StablecoinTemplateConfig memory cfg = defaultStablecoinConfig();
        (address predicted, bytes32 salt) =
            factory.mineStablecoinSalt(IPoolManager(address(manager)), address(this), cfg);

        address deployed = factory.deployStablecoin(IPoolManager(address(manager)), cfg, salt);
        assertEq(deployed, predicted);
    }

    function test_MineAndDeployRWAHook() public {
        RWATemplateConfig memory cfg = defaultRWAConfig();
        (address predicted, bytes32 salt) = factory.mineRWASalt(IPoolManager(address(manager)), address(this), cfg);

        address deployed = factory.deployRWA(IPoolManager(address(manager)), cfg, salt);
        assertEq(deployed, predicted);
    }

    function test_MineAndDeployLongTailHook() public {
        LongTailTemplateConfig memory cfg = defaultLongTailConfig();
        (address predicted, bytes32 salt) = factory.mineLongTailSalt(IPoolManager(address(manager)), address(this), cfg);

        address deployed = factory.deployLongTail(IPoolManager(address(manager)), cfg, salt);
        assertEq(deployed, predicted);
    }
}
