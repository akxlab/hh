pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT

/*
    @title draft IRBAC interface (Resource Based Access Control)
    @description draft of the IRBAC interface
    @author AKX LABS <info@akxlab.com>
 */ 

 interface IRBAC {

  
    function initialize() external;

    /**
        @dev grants permissions to a user to a resourceID (usually a contract)
        @param resourceID bytes32 keccak256 of the resource name and prefix (to make sure it does not collide with another resource)
        @param permissionBytes keccak256 of the permission name + Prefix (CAN_ or CANT_) + ACTION (ie.: CAN_WRITE_) + TOPIC (ie.: CAN_WITHDRAW_ETHER or CAN_DEPOSIT_TOKEN)
        @param subject the Address you want to grant the permission to
     */
    function grant(bytes32 resourceID, bytes32 permissionBytes, address subject) external;

    function revoke(bytes32 resourceID, bytes32 permissionBytes, address subject) external;

    /**
        @dev can is to know if the subject CAN perform the specific option, returns true if it CAN, false if it CANNOT
        @param resourceID bytes32 keccak256 of the resource name and prefix (to make sure it does not collide with another resource)
        @param permissionBytes keccak256 of the permission name + Prefix (CAN_ or CANT_) + ACTION (ie.: CAN_WRITE_) + TOPIC (ie.: CAN_WITHDRAW_ETHER or CAN_DEPOSIT_TOKEN)
        @param subject the Address you want to grant the permission to
     */

    function can(bytes32 resourceID, bytes32 permissionBytes, address subject) external returns(bool);
     /**
        @dev cannot is to know if the subject CANNOT perform the specific option, returns true if it CANNOT, false if it CAN
        @param resourceID bytes32 keccak256 of the resource name and prefix (to make sure it does not collide with another resource)
        @param permissionBytes keccak256 of the permission name + Prefix (CAN_ or CANT_) + ACTION (ie.: CAN_WRITE_) + TOPIC (ie.: CAN_WITHDRAW_ETHER or CAN_DEPOSIT_TOKEN)
        @param subject the Address you want to grant the permission to
     */

    function cannot(bytes32 resourceID, bytes32 permissionBytes, address subject) external returns(bool);

    

    /**
        @dev simple IERC165 implementation
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);



 }