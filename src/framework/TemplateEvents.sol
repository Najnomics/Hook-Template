// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract TemplateEvents {
    event TemplateDeployed(bytes32 indexed templateId, address indexed hook, address indexed admin, bytes32 configHash);
    event ConfigUpdated(bytes32 indexed templateId, bytes32 indexed poolId, bytes32 configHash, uint256 effectiveAt);
    event GuardTriggered(
        bytes32 indexed templateId, bytes32 indexed poolId, bytes32 indexed guard, int256 contextValue
    );
    event FeeUpdated(bytes32 indexed templateId, bytes32 indexed poolId, uint24 oldFee, uint24 newFee);
    event ModeTransitioned(bytes32 indexed templateId, bytes32 indexed poolId, bytes32 oldMode, bytes32 newMode);
}
