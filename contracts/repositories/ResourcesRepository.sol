pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT

import "./entities/Resource.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";

contract ResourcesRepository is Initializable, ReentrancyGuardUpgradeable, Resource {
    address public resourceRepositoryOwner;

    mapping(string => bool) private _rExists;
    mapping(bytes32 => bool) private _ids;
    mapping(bytes32 => string) private _idToString;
    mapping(string => bytes32) private _resourceIDs;
    mapping(bytes32 => address) private _resourceAddresses;
    mapping(bytes32 => Resource.ResourceTypes) private _resourceTypes;
    mapping(bytes32 => mapping(Resource.ResourceTypes => bool))
        private _isResourceType;
    mapping(bytes32 => Resource.ResourceRecord) private _resourceRecords;
    mapping(address => mapping(bytes32 => bool)) public ValidAKXResourceAddress;
    mapping(address => bytes32) private addressToID;

    using CountersUpgradeable for CountersUpgradeable.Counter;
    CountersUpgradeable.Counter internal _index;

    constructor() {
        resourceRepositoryOwner = msg.sender;
    }

    function _addResource(
        string memory name,
        Resource.ResourceTypes rType,
        address resAddr,
        address owner_
    ) internal returns (bytes32) {
        bytes32 id = _calculateResourceID(name, rType);
        _rExists[name] = true;
        _ids[id] = true;
        _resourceIDs[name] = id;
        _resourceAddresses[id] = resAddr;
        _resourceTypes[id] = rType;
        _isResourceType[id][rType] = true;
        ValidAKXResourceAddress[resAddr][id] = true;
        Resource.ResourceRecord memory rr = Resource.ResourceRecord({
            name: name,
            rType: rType,
            rAddress: resAddr,
            owner: owner_
        });
        _resourceRecords[id] = rr;
        return id;
    }

    function _calculateResourceID(
        string memory name,
        Resource.ResourceTypes rType
    ) internal returns (bytes32) {
        uint256 nonce = _index.current();
        bytes memory toKeccak = abi.encode(name, rType, nonce);
        _index.increment();
        return keccak256(toKeccak);
    }

    function addResource(
        string memory name,
        Resource.ResourceTypes rType,
        address resAddr,
        address owner_
    ) public onlyOwner returns (bytes32) {
        require(_rExists[name] != true, "resource already exists");
        return _addResource(name, rType, resAddr, owner_);
    }

    function removeResource(bytes32 id) public onlyOwner {
        require(_ids[id] == true, "resource does not exists");

        string memory name = _idToString[id];
        delete _resourceIDs[name];
        address resAddr = _resourceAddresses[id];
        delete _resourceAddresses[id];
        Resource.ResourceTypes rtype = _resourceTypes[id];
        delete _isResourceType[id][rtype];
        delete _resourceTypes[id];
        delete _idToString[id];
        delete _rExists[name];
        delete _resourceRecords[id];
        delete addressToID[resAddr];
        delete ValidAKXResourceAddress[resAddr][id];
        delete _ids[id];
    }

    function isValidAKXEcosystemResource(address resAddr)
        external
        nonReentrant
        returns (bool)
    {
        bytes32 id = addressToID[resAddr];
        return ValidAKXResourceAddress[resAddr][id] == true;
    }

    function initResource(
        string memory name,
        string memory rType,
        address _rAddress
    ) public override onlyOwner {
        addResource(name, strToType[rType], _rAddress, msg.sender);
    }

    function initResourceRecord(address owner, bytes memory merkleProof)
        public
        override
        onlyOwner
    {}

    function getResourceID(address addr) public nonReentrant returns (bytes32) {
        return addressToID[addr];
    }

    function getResource(bytes32 id) public nonReentrant returns(ResourceRecord memory) {
        return _resourceRecords[id];
    }

    function getResourceType(bytes32 id) public nonReentrant returns(Resource.ResourceTypes) {
    return _resourceTypes[id];
    }

    function isBridge(bytes32 id) public nonReentrant returns(bool) {
        return getResourceType(id) == Resource.ResourceTypes.BRIDGE;
    }

    function isRepository(bytes32 id) public nonReentrant returns(bool) {
        return getResourceType(id) == Resource.ResourceTypes.REPOSITORY;
    }

    function isContract(bytes32 id) public nonReentrant returns(bool) {
        return getResourceType(id) == Resource.ResourceTypes.CONTRACT;
    }

    function isGovernor(bytes32 id) public nonReentrant returns(bool) {
        return getResourceType(id) == Resource.ResourceTypes.GOVERNOR;
    }

    function isDapp(bytes32 id) public nonReentrant returns(bool) {
        return getResourceType(id) == Resource.ResourceTypes.DAPP;
    }

    function isNft(bytes32 id) public nonReentrant returns(bool) {
        return getResourceType(id) == Resource.ResourceTypes.NFT;
    }

     function isUser(bytes32 id) public nonReentrant returns(bool) {
        return getResourceType(id) == Resource.ResourceTypes.USER;
    }

    function getResourceTypeAsString(bytes32 id) public nonReentrant returns (string memory) {
        if(isBridge(id) == true) return "bridge";
        if(isRepository(id) == true) return "repository";
        if(isContract(id) == true) return "contract";
        if(isGovernor(id) == true) return "governor";
        if(isDapp(id) == true) return "dapp";
        if(isNft(id) == true) return "nft";
        if(isUser(id) == true) return "user";
        revert("invalid resource type or not supported");
    }



    function isValidResource(address addr) public nonReentrant returns(bool) {
        bytes32 id = getResourceID(addr);
        return ValidAKXResourceAddress[addr][id];
    }

    modifier onlyOwner() {
        require(msg.sender == resourceRepositoryOwner, "access denied");
        _;
    }
}
