pragma solidity 0.8.15;

// SPDX-License-Identifier: GPL-3.0-only


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./Lock.sol";



abstract contract BaseSafeERC20 is Lock, ERC20Burnable, ReentrancyGuard {

    using Math for uint256;
    using SafeERC20 for IERC20;

   

    constructor(uint256 unlockTime)

    
    receive() payable external nonReentrant {

    }


}