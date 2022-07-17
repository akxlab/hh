// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;


import "./interfaces/ISalesRules.sol";
import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";



abstract contract SalesRulesBaseContract is ISalesRules, Ownable {

    mapping(bytes32 => SaleRule) private _rules;
    mapping(string => bytes32) private _rulesByName;
    mapping(bytes32 => bool) private _ruleReverts;
    mapping(bytes32 => bool) private _ruleExists;
    mapping(uint256 => mapping(bytes32 => SaleRule)) private _ruleIndexes;
    mapping(bytes32 => mapping(bytes32 => bool)) private _hasCriteria;

    
    function revertOnError() public onlyOwner  view returns (bool) {
        return false;
    }
    function setupRule(string memory _ruleName, RuleType  _ruleType, Criteria[] memory criterias) public onlyOwner {
        bytes32 ruleid = keccak256(abi.encodePacked(_ruleName));
           require(saleRuleExists(ruleid) != true, "akx/rule-already-exists");
        SaleRule memory sr = SaleRule(_ruleName, ruleid, _ruleType, criterias);
        emit NewRuleCreated(address(this), msg.sender, sr);
    }

    function _addCriteriaToRule(Criteria memory criteria, bytes32 ruleId) internal  {
        
        bytes32 cid = keccak256(abi.encodePacked(ruleId, criteria.name));
        _hasCriteria[ruleId][cid] = true;
        _rules[ruleId].rulesCriterias[ _rules[ruleId].rulesCriterias.length] = criteria;
    }

    function saleRuleExists(bytes32 id) internal view returns(bool) {
        return _ruleExists[id];
    }

    function saleHasCriteria(bytes32 ruleid, bytes32 id) internal view returns(bool) {
       require(_ruleExists[ruleid] == true, "akx/invalid-rule-id");
        if(_hasCriteria[ruleid][id] != true) {
            return false;
        }
        return true;
    }


    modifier ruleExists(bytes32 ruleid) {
        require(saleRuleExists(ruleid) == true, "akx/rule-not-exists");
        _;
    }

    modifier ruleNotExists(bytes32 ruleid) {
        require(saleRuleExists(ruleid) != true, "akx/rule-already-exists");
        _;
    }

}