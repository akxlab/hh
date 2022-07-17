// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface ISalesRules {

    event NewRuleCreated(address indexed forContract, address indexed from, SaleRule rule);
    event RuleTriggered(address indexed forContract, address indexed by, bytes32 ruleId);

    struct SaleRule {
        string name;
        bytes32 id;
        RuleType ruleType;
        Criteria[] rulesCriterias;
    }

    struct Criteria {
        string name;
        bytes32 id;
        CriteriaType cType;
        ValueType vType;
        bytes val;
    }

    enum CriteriaType {
        NONE,
        MAX_BUY,
        MAX_SELL,
        MIN_BUY,
        MIN_SELL,
        CAN_BUY_WHEN,
        CAN_SELL_WHEN,
        ONLY_IN_STATE,
        NOT_IN_STATE,
        ONLY_BADGES_TYPE,
        NOT_BEFORE_DATE,
        NOT_AFTER_DATE
    }

    enum ValueType {
        UINT256,
        STRING,
        UINT_ARRAY,
        STRING_ARRAY,
        ADDRESS,
        ADDRESS_ARRAY,
        DATE_TIME
    }

    enum RuleType {
        NONE,
        PRIVATE_SALE,
        PUBLIC_SALE,
        EVERYONE
    }

  
  


}