// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script, console2} from "forge-std/Script.sol";
import {TemplateFactory} from "../src/factory/TemplateFactory.sol";

contract DeployTemplateFactoryScript is Script {
    function run() external returns (TemplateFactory factory) {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(privateKey);
        factory = new TemplateFactory();
        vm.stopBroadcast();

        console2.log("TemplateFactory:", address(factory));
    }
}
