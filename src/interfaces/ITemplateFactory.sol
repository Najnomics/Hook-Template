// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {IPoolManager} from "@uniswap/v4-core/src/interfaces/IPoolManager.sol";
import {StablecoinTemplateConfig, RWATemplateConfig, LongTailTemplateConfig} from "../framework/TemplateTypes.sol";

interface ITemplateFactory {
    function mineStablecoinSalt(IPoolManager manager, address admin, StablecoinTemplateConfig calldata config)
        external
        view
        returns (address hookAddress, bytes32 salt);

    function mineRWASalt(IPoolManager manager, address admin, RWATemplateConfig calldata config)
        external
        view
        returns (address hookAddress, bytes32 salt);

    function mineLongTailSalt(IPoolManager manager, address admin, LongTailTemplateConfig calldata config)
        external
        view
        returns (address hookAddress, bytes32 salt);

    function deployStablecoin(IPoolManager manager, StablecoinTemplateConfig calldata config, bytes32 salt)
        external
        returns (address hook);

    function deployRWA(IPoolManager manager, RWATemplateConfig calldata config, bytes32 salt)
        external
        returns (address hook);

    function deployLongTail(IPoolManager manager, LongTailTemplateConfig calldata config, bytes32 salt)
        external
        returns (address hook);
}
