pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT

abstract contract Resource {

    string public ResourceName;
    bytes32 public ResourceType;

    struct ResourceRecord {
        string name;
        ResourceTypes rType;
        address rAddress;
        address owner;
      
    }

    enum ResourceTypes {
        CONTRACT,
        BRIDGE,
        REPOSITORY,
        PROXY,
        OPERATOR,
        GOVERNOR,
        DAPP
    }

    mapping(string => ResourceTypes) public strToType;

    bool internal setup = false;

    function initialize() public {
        require(setup != true, "already initialized");
        _initializeTypes();
    }

    function _initializeTypes() internal {
        strToType["contract"] = ResourceTypes.CONTRACT;
        strToType["bridge"] = ResourceTypes.BRIDGE;
        strToType["repository"] = ResourceTypes.REPOSITORY;
        strToType["proxy"] = ResourceTypes.PROXY;
        strToType["operator"] = ResourceTypes.OPERATOR; 
        strToType["governor"] = ResourceTypes.GOVERNOR;
        strToType["dapp"] = ResourceTypes.DAPP;  
        setup = true;
    }

    function getTypeByName(string memory name) public view returns(Resource.ResourceTypes) {
        return strToType[name];
    }

    function initResource(string memory name, bytes32 rType, address _rAddress) external virtual;

    function initResourceRecord(address owner, bytes memory merkleProof) external virtual;

    function encodeRecord(ResourceRecord memory rr) public pure returns(bytes memory) {
        return  abi.encode(rr);
    }

    function decodeRecord(bytes memory record) public pure returns(ResourceRecord memory) {
        return abi.decode(record, (ResourceRecord));
    }

}

