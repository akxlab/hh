// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "../../../node_modules/@openzeppelin/contracts/access/Ownable.sol";
import "./CriteriaLogic.sol";

   


abstract contract CriteriaFactory is Ownable, ISalesRules  {


   

    function buildCriteria(string memory _n, CriteriaType ct, ValueType vt, bytes memory val) public onlyOwner view returns(Criteria memory) {
        bytes32 id = keccak256(abi.encodePacked(_n));
        Criteria memory c = Criteria(_n, id, ct, vt, val);
        return c;
    }

    function decodeCriteria(bytes calldata c) public onlyOwner view returns(Criteria memory) {
        return abi.decode(c, (Criteria));
    }

    function encodeValue(bytes memory val, ValueType vt) public onlyOwner view {
        if(vt == ValueType.UINT256) {
            _encodeValueUint(val);
        }
        if(vt == ValueType.UINT_ARRAY) {
            _encodeValueUintArray(val);
        }
        if(vt == ValueType.STRING) {
            _encodeValueString(val);
        }
        if(vt == ValueType.STRING_ARRAY) {
            _encodeValueStringArray(val);
        }
        if(vt == ValueType.ADDRESS) {
            _encodeValueAddress(val);
        }
        if(vt == ValueType.ADDRESS_ARRAY) {
            _encodeValueAddressArray(val);
        }
        if(vt == ValueType.DATE_TIME) {
            _encodeDateTime(val);
        }
    }

    function _encodeValueUint(bytes memory val) internal pure returns(uint256) {
        return abi.decode(val, (uint256));
    }

    function _encodeValueUintArray(bytes memory val) internal pure returns(uint256[] memory) {
        return abi.decode(val, (uint256[]));
    }

    function _encodeValueString(bytes memory val) internal pure returns(string memory) {
        return abi.decode(val, (string));
    }

    function _encodeValueStringArray(bytes memory val) internal pure returns(string[] memory) {
        return abi.decode(val, (string[]));
    }

    function _encodeValueAddress(bytes memory val) internal pure returns(address) {
        return abi.decode(val, (address));
    }

    function _encodeValueAddressArray(bytes memory val) internal pure returns(address[] memory) {
        return abi.decode(val, (address[]));
    }

    function _encodeDateTime(bytes memory val) internal pure returns(uint256) {
        return abi.decode(val, (uint256));
    }

}