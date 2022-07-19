pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT

/*
    @title RBAC base contract (Resource Based Access Control)
    @description the contract all RBAC controllers should derive from 
    @author AKX LABS <info@akxlab.com>
 */

import "./interfaces/draft-IRBAC.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165.sol";
import "./BaseRoles.sol";

abstract contract  RBAC is IRBAC, ERC165, AccessControlEnumerable, ReentrancyGuard {

    enum RWUDPermissions {
        NONE,
        READ,
        WRITE,
        UPDATE,
        UPGRADE,
        DELETE
    }

    enum Access {
        NONE,
        CAN,
        CANNOT,
        CAN_ONLY_IF_ROLE,
        DENY_ALL,
        ALLOW_ALL
    }

    mapping(bytes32 => address) private _resources;
    mapping(bytes32 => bytes4) private _resourcesInterfaces;
    mapping(bytes32 => mapping(address => bool)) private _resourcesCreators;
    mapping(bytes32 => mapping(address => mapping(bytes32 => bool))) public hasPermission;

    bytes4 public constant PREFIX = bytes4(keccak256("_RBAC_"));
    bytes4 public constant ACCESS_CAN = bytes4(keccak256("CAN_"));
    bytes4 public constant ACCESS_CANNOT = bytes4(keccak256("CANT_"));
    bytes2 public constant CAN_VERIFIER_2BYTE = bytes2(abi.encode(Access.CAN));
    bytes2 public constant ALLOW_ALL_VERIFIER_2BYTE = bytes2(abi.encode(Access.ALLOW_ALL));

    bool internal isInit = false;
address public admin = address(0x0);

    bytes32 public constant RBAC_RES_ID_MAGIC = keccak256("RBAC_RES_ID_MAGIC");
    bytes32 public constant RBAC_ADMIN = keccak256("RBAC_ADMIN");
    bytes32 public constant RBAC_ALL_PERMISSIONS = keccak256(abi.encode(RBAC_RES_ID_MAGIC, PREFIX, ACCESS_CAN, ALLOW_ALL_VERIFIER_2BYTE, bytes1(0)));

    mapping(string => mapping(bytes32 => bytes32)) private _permissionsByStringWithResourceID;
    mapping(string => bytes32) public _permissions;
    mapping(string => bool) private _permissionExists;


    function initialize() public override ifNotInitialized  onlyRole(BaseRoles.GLOBAL_ADMIN_ROLE) {
      
    }

    function __RBAC_init(address globalAdmin) public ifNotInitialized onlyRole(BaseRoles.GLOBAL_ADMIN_ROLE) {
  _setupRole(RBAC_ADMIN, globalAdmin);
        _setupPermission(RBAC_ALL_PERMISSIONS, RBAC_RES_ID_MAGIC, globalAdmin);
        _resources[keccak256("RBAC")] = address(this);
        _resourcesInterfaces[keccak256("RBAC")] = type(IRBAC).interfaceId;
        _resourcesCreators[RBAC_RES_ID_MAGIC][globalAdmin] = true;
    }

    function _setupPermission(bytes32 permissionBytes, bytes32 resourceID, address subject) public  onlyRole(BaseRoles.GLOBAL_ADMIN_ROLE) {
        require(admin == address(0x0), "akx-rbac/admin-already-setup");
        grant(resourceID, permissionBytes, subject);
    }

    function _addPermission(string memory pString, bytes32 permissionBytes, bytes32 resourceID) internal {
            _permissionsByStringWithResourceID[pString][permissionBytes] = resourceID;
            _permissions[pString] = permissionBytes;
    }

    function addPermission(string memory pString, bytes32 resourceID) public onlyRole(RBAC_ADMIN) {
        require(_permissionExists[pString] != true, "akx-rbac/cannot-add-permission");
        bytes32 pBytes = keccak256(abi.encodePacked(pString));
        _addPermission(pString, pBytes, resourceID);
        _permissionExists[pString] == true;
    }


    /**
        @dev grants permissions to a user to a resourceID (usually a contract)
        @param resourceID bytes32 keccak256 of the resource name and prefix (to make sure it does not collide with another resource)
        @param permissionBytes keccak256 of the permission name + Prefix (CAN_ or CANT_) + ACTION (ie.: CAN_WRITE_) + TOPIC (ie.: CAN_WITHDRAW_ETHER or CAN_DEPOSIT_TOKEN)
        @param subject the Address you want to grant the permission to
     */
    function grant(bytes32 resourceID, bytes32 permissionBytes, address subject) public onlyRole(RBAC_ADMIN) {
        require(hasPermission[resourceID][subject][permissionBytes] != true, "akx-rbac/already-has-permission");
        hasPermission[resourceID][subject][permissionBytes] = true;
    }

    function revoke(bytes32 resourceID, bytes32 permissionBytes, address subject) public onlyRole(RBAC_ADMIN) {
    require(hasPermission[resourceID][subject][permissionBytes] == true, "akx-rbac/revoke-invalid-permissionid");
    delete hasPermission[resourceID][subject][permissionBytes];
    }

    /**
        @dev can is to know if the subject CAN perform the specific option, returns true if it CAN, false if it CANNOT
        @param resourceID bytes32 keccak256 of the resource name and prefix (to make sure it does not collide with another resource)
        @param permissionBytes keccak256 of the permission name + Prefix (CAN_ or CANT_) + ACTION (ie.: CAN_WRITE_) + TOPIC (ie.: CAN_WITHDRAW_ETHER or CAN_DEPOSIT_TOKEN)
        @param subject the Address you want to grant the permission to
     */

    function can(bytes32 resourceID, bytes32 permissionBytes, address subject) external nonReentrant returns(bool) {
        return  hasPermission[resourceID][subject][permissionBytes] == true;
    }
     /**
        @dev cannot is to know if the subject CANNOT perform the specific option, returns true if it CANNOT, false if it CAN
        @param resourceID bytes32 keccak256 of the resource name and prefix (to make sure it does not collide with another resource)
        @param permissionBytes keccak256 of the permission name + Prefix (CAN_ or CANT_) + ACTION (ie.: CAN_WRITE_) + TOPIC (ie.: CAN_WITHDRAW_ETHER or CAN_DEPOSIT_TOKEN)
        @param subject the Address you want to grant the permission to
     */

    function cannot(bytes32 resourceID, bytes32 permissionBytes, address subject) external nonReentrant returns(bool) {
        return  hasPermission[resourceID][subject][permissionBytes] != true;
    }

    /**
        @dev simple IERC165 implementation
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, ERC165,IRBAC) returns (bool) {
        return (interfaceId ==  type(IERC165).interfaceId || interfaceId == type(IRBAC).interfaceId);
    }
    

    modifier ifNotInitialized() {
        require(isInit == false, "already initialized");
        _;
    }




}