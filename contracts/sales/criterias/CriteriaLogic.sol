// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "../SalesRulesBaseContract.sol";
import "./CriteriaFactory.sol";
import "../lib/SalesStates.sol";

abstract contract CriteriaLogic is SalesRulesBaseContract, SalesStates {


}

abstract contract CriteriaBuySell is CriteriaLogic {

    function applyCriteria(Criteria memory c, uint256 msgValue) internal view {
         uint256 val = abi.decode(c.val, (uint256));
        if(CriteriaType.MAX_BUY == c.cType) {
            require(msgValue <= val, "akx/buying-too-much");
            return;
        }
        if(CriteriaType.MIN_BUY == c.cType) {
            require(msgValue > val, "akx/buying-too-little");
            return;
        }
        if(CriteriaType.MAX_SELL == c.cType) {
             require(msgValue <= val, "akx/selling-too-much");
            return;
        }
         if(CriteriaType.MIN_SELL == c.cType) {
             require(msgValue > val, "akx/selling-too-little");
            return;
        }
         if(CriteriaType.CAN_SELL_WHEN == c.cType) {
             require(block.timestamp >= val, "akx/too-early-tosell");
            return;
        }

         if(CriteriaType.CAN_BUY_WHEN == c.cType) {
             require(block.timestamp >= val, "akx/too-early-tobuy");
            return;
        }
        

    }

}

abstract contract CriteriaStates is CriteriaLogic {

    function applyCriteria(Criteria memory c, SaleStates memory s) internal view {

        uint256 val = abi.decode(c.val, (uint256));
        if(c.cType == CriteriaType.NOT_AFTER_DATE) {
            require(block.timestamp < val, "akx/not-after-date");
        }
         if(c.cType == CriteriaType.NOT_BEFORE_DATE) {
            require(block.timestamp > val, "akx/not-before-date");
        }
         if(c.cType == CriteriaType.ONLY_IN_STATE) {
            require(s.state == abi.decode(c.val, (StateFlags)), "akx/only-state");
        }
         if(c.cType == CriteriaType.NOT_IN_STATE) {
            require(s.state != abi.decode(c.val, (StateFlags)), "akx/notin-state");
        }
        return;

    }

}