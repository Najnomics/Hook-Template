// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

error Unauthorized(address caller);
error InvalidConfig(bytes32 field);
error GuardViolation(bytes32 guard);
error UnsupportedPool(bytes32 poolId);
