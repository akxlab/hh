pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT


interface IBaseSafeERC20Configurator {

    struct TokenInfo {
        string name;
        string symbol;
        uint8 decimals;
        uint256 totalSupply;
    }

    struct Cappable {
        uint256 cap;
    }

    struct Lockable {
        uint256 unlockTime;
    }

    struct ERC20Options {
        bool isCappable;
        bool isLockable;
        bool isMintable;
        bool isBurnable;
        bool isStakable;
        bool isBridgeable;
        bool isPauseable;
        address initialMintingReceiver;
        uint256 premintAmount;
    }

    /**
        @notice initialize the new erc20 token parameters
        @param tokenInfo TokenInfo abi.encoded struct
        @param options ERC20Options that defines what the token can do
     */

    function initialize(bytes calldata tokenInfo, bytes calldata options) external;
    function decodeOptions() external returns(ERC20Options memory);
    function decodeTokenInfo() external returns(TokenInfo memory);


}