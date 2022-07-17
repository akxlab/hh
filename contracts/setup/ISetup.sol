// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface ISetup {
    event ContractSetup(address indexed _contract, address indexed from, bool success);

    struct SetupArgs {
        string argType;
        string key;
        string val;
    }

   

}