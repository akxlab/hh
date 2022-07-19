pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT

interface IAKXResolver {

    function authorized(bytes32 hash, address addr) external returns(bool);


}