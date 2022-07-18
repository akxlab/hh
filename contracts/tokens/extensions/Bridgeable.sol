pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT


abstract contract Bridgeable {

    address public bridge;

    constructor(address bridgeAddress) {
        bridge = bridgeAddress;
    }

    modifier onlyBridge() {
        require(msg.sender == bridge, "akx-bridgeable/access-denied");
        _;
    }

}
