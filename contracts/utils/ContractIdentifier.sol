// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;



import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
   
abstract contract ContractIdentifer is ReentrancyGuardUpgradeable {

   modifier onlyContract() {
        require(isContract(msg.sender) == true, "only contracts can call");
        _;
    }

    function isContract(address addr) public nonReentrant returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
    }
}
