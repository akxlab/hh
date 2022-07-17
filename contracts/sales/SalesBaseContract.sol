// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./lib/SalesStates.sol";
import "../setup/ISetup.sol";

abstract contract SalesBaseContract is SalesStates, ISetup {

    constructor(address saleOperator_, bool startPaused_) SalesStates(saleOperator_, startPaused_) {

    }

    function getState() public view returns (StateFlags) {

        return currentState;

    }

       

    function setup(bytes calldata args) public onlyStateOperator(msg.sender)  virtual {}


}