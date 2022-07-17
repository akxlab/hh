// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import  "./SalesBaseContract.sol";
import "../../node_modules/@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "../tokens/CollateralizedVault.sol";
import "../../node_modules/@openzeppelin/contracts/access/Ownable.sol";

contract PrivateSale is SalesBaseContract, Ownable,  ReentrancyGuard {

    address private _collateralizedSharesContract;
    CollateralizedVault private _cVault;
    uint256 public constant PRIVATE_SALE_START_DATE = 1658721600; // july 25th 2022 00:00:00 EST
    uint256 public constant PRIVATE_SALE_MAX_DURATION = 10 days;

    mapping(address => uint256) public pledges;
    mapping(address => bool) public allowed;
    uint256 public totalPledged;
    uint256 public totalPledgers;
    
    SalesStates private states;

    mapping(address => uint256) private _vipNftIds;

    struct Subscription {
        address holder;
        string email;
        string twitterHandle;
        address referrer;
        uint256 nftTokenID;
        uint256 internalID;
    }

    mapping(address => Subscription) internal subscriptions;




    constructor(address sharesToken) SalesBaseContract(msg.sender, false) {
        _collateralizedSharesContract = sharesToken;
        _cVault = new CollateralizedVault(sharesToken, "vAKX-A", "vAKX.A");
    }

    function startPrivateSale() public  onlyOwner {
        if(block.timestamp <= PRIVATE_SALE_START_DATE) {
             if(states.isPaused() == true) {
                states.UnPauseContract();
             }
        } else {
            if(!states.isPaused()) {
            states.PauseContract();
            }
        }
    }

    function showMeYourPass(uint256 tokenID) external nonReentrant returns(bool) {

        require(_vipNftIds[msg.sender] == tokenID, "akx/invalid-vip-nft-for-address");
        return true;
    }

    function pledge() external payable nonReentrant returns(uint256) {
        require(msg.value > 0, "akx/no-zero-amount");
        require(msg.sender != address(0x0), "akx/no-zero-address");
        require(states.isPaused() != true, "sale is not started");
        require(allowed[msg.sender] == true, "you are not registered");
        uint256 shares = _cVault.deposit(msg.value, msg.sender);
        return shares;
    }

    function subscribeToPrivateSale(bytes calldata subscription) external nonReentrant returns(Subscription memory) {
        Subscription memory sub = abi.decode(subscription, (Subscription));
        require(allowed[sub.holder] != true, "already subscribed");
        if (sub.holder == address(0x0)) { revert("bad wallet address"); }
        return sub;
    }

  


    receive() external payable nonReentrant {
        
        revert("you cannot directly deposit to this contract");
    }

    fallback() external payable nonReentrant {
         revert("you cannot directly deposit to this contract");
    }

}