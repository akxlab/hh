pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT

/*
    @title Base Roles
    @description the base roles a contract should / can have
 */ 

 library BaseRoles {

    bytes32 public constant GLOBAL_ADMIN_ROLE = keccak256("GLOBAL_ADMIN_ROLE");
    bytes32 public constant OPERATOR_ROLE = keccak256("OPERATOR_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");
    bytes32 public constant OFFCHAIN_ORACLE_ROLE = keccak256("OFFCHAIN_ORACLE_ROLE");
    bytes32 public constant WITHDRAWER_ROLE = keccak256("WITHDRAWER_ROLE");
    bytes32 public constant VALIDATOR_ROLE = keccak256("VALIDATOR_ROLE");
    bytes32 public constant HOLDER_ROLE = keccak256("HOLDER_ROLE");
    bytes32 public constant DELEGATE_ROLE = keccak256("DELEGATE_ROLE");
    bytes32 public constant DELEGATOR_ROLE = keccak256("DELEGATOR_ROLE");
    bytes32 public constant FACTORY_OPERATOR_ROLE = keccak256("FACTORY_OPERATOR_ROLE");
    bytes32 public constant BRIDGE_ROLE = keccak256("BRIDGE_ROLE");

 }