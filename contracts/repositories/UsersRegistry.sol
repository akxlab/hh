// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";



contract UsersRegistry is AccessControlEnumerable  {

    using ECDSA for bytes32;
    using Counters for Counters.Counter;

    address private _factory;

    Counters.Counter private _tokenIdCounter;

    struct User {
        string keyHash;
        address owner;
        string nickname;
    }

    constructor() {}

    function verifySigner(address _signer, bytes memory signature) public view returns(bool) {
        require(_signer == keccak256(
            abi.encodePacked(
                "\x19Ethereum Signed Message:\n32",
                bytes32(uint256(uint160(msg.sender)))
            )).recover(signature)
        , "signer address mismatch");
        return true;
    }



}
