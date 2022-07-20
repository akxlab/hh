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

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PRESALE_ROLE = keccak256("PRESALE_MINTER_ROLE");

    bool public isPresale;

    constructor() ERC20(NAME, SYMBOL) ERC20Permit(NAME) {
        isPresale = true;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function grantPresaleRole(address presale) external onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(PRESALE_ROLE, presale);
    }

    function mint(address _to, uint256 qty) public onlyRole(MINTER_ROLE) {
        super._mint(_to, qty);
    }

    function mintForPresale(address _to, uint256 qty) public onlyRole(PRESALE_ROLE) {
        super._mint(_to, qty);
    }

    

 



}