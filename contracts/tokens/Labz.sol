// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "../../node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "../../node_modules/@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "../../node_modules/@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "../../node_modules/@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";


contract Labz is ERC20, ERC20Burnable, ERC20Permit, AccessControlEnumerable {

    string public constant NAME = "AKX Labz Token";
    string public constant SYMBOL = "LABZ";
    uint8 public constant DECIMAL = 18;
    uint256 public cap;
    uint256 public chainId;

    constructor(address multisig) ERC20(NAME, SYMBOL) ERC20Permit(NAME) {

    }

    function setup(address multisig) internal {

    }



}