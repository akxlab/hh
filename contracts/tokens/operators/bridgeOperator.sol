pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT

import "../BaseERC20.sol";
import "../extensions/Bridgeable.sol";

interface IBridgeOperator {
    struct DepositRecord {
        address _tokenAddress;
        uint8   _destinationChainID;
        bytes32 _resourceID;
        bytes   _destinationRecipientAddress;
        address _depositer;
        uint    _amount;
    }

    event NewBridgeDeposit(address indexed from, uint256 fromChainID, uint256 toChainID, address indexed to);
    event NewDepositRecord(uint64 indexed recordID);

    function getDepositRecord(uint64 depositNonce, uint64 destId) external returns (DepositRecord memory);

    function deposit(
        bytes32 resourceID,
        uint8 destChainID,
        uint64 depositNonce,
        address depositer,
        bytes calldata data
     ) external;
}


contract BridgeOperator is IBridgeOperator, BaseSafeERC20, Bridgeable {

    mapping(uint64 => mapping(uint64 => DepositRecord)) public depositRecords;

    constructor(uint256 lockTime, address bridgeAddress) BaseSafeERC20(lockTime) Bridgeable(bridgeAddress) {

    }

    // @dev the deposit nonce is generated by the bridge contract
    function getDepositRecord(uint64 depositNonce, uint64 destId) external view override returns (DepositRecord memory) {
        return depositRecords[destId][depositNonce];
    }

    /**
        @notice A deposit is initiatied by making a deposit in the Bridge contract.
        @param destChainID Chain ID of chain tokens are expected to be bridged to.
        @param depositNonce This value is generated as an ID by the Bridge contract.
        @param depositer Address of account making the deposit in the Bridge contract.
        @param data Consists of: abi encoded struct DepositData
        @dev Depending if the corresponding {tokenAddress} for the parsed {resourceID} is
        marked true in {_burnList}, deposited tokens will be burned, if not, they will be locked.
     */

     struct DepositData {
        address from;
        address to;
        uint256 amount;
     }

     function deposit(
        bytes32 resourceID,
        uint8 destChainID,
        uint64 depositNonce,
        address depositer,
        bytes calldata data
     ) external override onlyBridge {

        DepositData memory dd = abi.decode(data, (DepositData));


     }


}