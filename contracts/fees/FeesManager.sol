// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract FeeManager is Ownable, ReentrancyGuard {

    event FeeDeposited(address indexed from, uint256 amount);

    address public feeTokenAddress;
    IERC20 private _feeToken;

    uint256 public baseFee = 2_5_0_0_0;
    uint256 public mantissa = 1e4;
    uint256 public consensusRoundsStaticFee = 0.00025 ether;

    mapping(uint256 => uint256) internal _feesIndex;
    mapping(uint256 => bool) internal collected;
    uint256[] private fees;
    uint256 public totalFeesCollected;

    address public feeWallet;

    using SafeERC20 for IERC20;
    using Math for uint256;

    constructor(address _fta) {
        feeTokenAddress = _fta;
        _feeToken = IERC20(_fta);
    }

    function _calculateTxFee(uint256 amount) internal view returns(uint256) {
        return baseFee.mulDiv(amount, mantissa);
    }

    function _recordFees(uint256 amount) internal returns(uint256){
        uint256 index = fees.length;
        uint256 fee = _calculateTxFee(amount);
        if(index == 0) {
            fees[0] = fee;
            _feesIndex[0] = fees[0];
        } else {
            fees[index] = fee;
            _feesIndex[index] = fees[index];
        }

        index += 1;
        return fee;

    }

    function getTxFee(uint256 amount) public onlyOwner returns(uint256) {
        return _recordFees(amount);
    }

    function collectFees() public onlyOwner {
        for(uint256 j = 0; j < fees.length; j++) {
            _feeToken.safeTransfer(payable(feeWallet), fees[j] * 1e18);
            totalFeesCollected += fees[j];
            delete fees[j];
            delete _feesIndex[j];
            collected[j] = true;
        }
    }

    function getConsensusTxFee(uint256 roundNum) public nonReentrant returns(uint256) {
        return roundNum.mulDiv(consensusRoundsStaticFee, 1);
    }


    receive() payable external nonReentrant {
        require(msg.sender != address(0), "akx/nozeroaddress");
        require(msg.value > 0, "akx/invalid-amount");
        emit FeeDeposited(msg.sender, msg.value);
    }

}