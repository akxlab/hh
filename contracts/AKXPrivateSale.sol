pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT

/**

                                  &&&/&&&                           
                                  &&&/*****&&&                        
                           &&&&%*,,,.,#&&&&&*&&/                      
                        &&&//***,,,,....  .&&&&&&                     
                      &&%////***,,,,....  ...%&%&                     
                   &&&&//////***,,,,@@@@@@...,*&&&&&                  
              &&&/%&&&#//////**//**@@..@@@ ...,*%&&&&&*&&*             
           &&&**(&&&&&///////&@@@@@@@@@.   ..,/&&&&&&&**&&&          
        &&&/*****&&&&&%//////*@(/@@@@*..  .  .*&&&&&&&******&&&       
    &&&****&&&&&&&&//////@@@#,(@&...  .   /&&&&&&&&&&#******%&&   
      (&&&&&&&&&&&&&,,#&&////***,,,,....    .&&&*,#&&&&&&&&&&&&&(     
      /&&&&&&&*,,,,,....#&&//***,,,,....  .&&(,....,,,,,/&&&&&&&      
     &&&%/&&,///%&&&&&(,,,./&&&&%/***%&&&&*..,,,%&&&&&(///(&&/&&&&    
    &&(//&&,//&&&&//&&&&&&&&*,,,,,,,,,,,,,(&&&&&&&& ,&&&&/*,&&//%&%   
   &%/#&&&,,/&&&&/&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&%,*&&&&*,%&&&//&&  
&&&&&&%/&&&,,&&&&/& .  &&#&&&&&&&&&&&&&&&&&&&*&.  % ,*&&&/,,&&&/&&&&&&
  ,&&/%&&&&&,,%&&&//%&&&(.*&&&&&&&&&&&&&&&&&//%&&&/ .&&&/,,&&&&&((&&  
  &&&/#&&%&&&,,,&&&&&&&&&&&&%&&&&#*,*%&&&&&&&&&&&&&&&&&,,#&&&/&&*, 
   &&&/////&%,,,,,,,,,,,,,,,,,,#&&&,&&&,,,,,,,,,,,,,,,,,,,&&/////&&&  
    &&&&&&&&&,,,,/&&&&&&,,,,,&&&&&&&&&&&&&,,,,,&&&&&&,,,,,&&&&&&&&(   
         /&//&&&&/(&&&,,,..............,,,,,,,/,,&&&/#&&&%/(&         
          &///*///&&&,*&,..........,,,,,,,,,,,,&,,&&#*(&         
          //*/**%&&,*//#&,,.............,,&//*,,&&/**/*//&.         
           //&&&,/*////(&&#*,,,/%&&//,,,,*,&&%//&/&(&%          
                    ///,,,,,,,,,,,,,,,,&&&&&& &&*           
                        ///*,,,,,,,,,,,*,&&&&&&&&#                
                            ////*,,&&&&&&%&&, /*                  
                                                    

  /**
  THIS CONTRACT WILL BE STOPPED ONCE THE PRIVATE SALE IS OVER
    PRIVATE SALE STARTS ON JULY 25TH 2022 AND WILL LAST 10 DAYS.
   */  
 
import "./tokens/Labz.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./utils/draft-EmergencyBreak.sol";
import "./AKXPsACL.sol";


contract PrivateSale is ReentrancyGuard, AccessControlEnumerable, AKXPsACL, EmergencyBreak {
    uint64 public constant startOn = 1658721609;
    uint64 public constant endsOn = 1659672009;

    using Math for uint256;


    address private _authenticator;

    address public labzTokenAddress;

    address public badgesFactory;

    address public multisig;

    uint256 public minLockTime = 90 days;

    uint256 public price;

    uint256 private mantissa = 1e4;

    uint256 public exchangeRatio;

    uint256 public chainID;

    uint256 public maxCirculatingSupply = 75000000 * 1e18; // 75M LABZ available for private sale

    Labz private labzToken;

    bool public privateSaleStarted;
    bool public privateSaleEnded;

    uint256 public totalHolders;
    uint256 public totalETH;
    uint256 public totalMATICS;
    uint256 public daysLeft;
    uint256 public countdown;
    uint256 public labzLeft;
    uint256 public labzMinted;

  



    /**
        @dev maxTotalAmountPerHoldersInLabz is the maximum a holder can hold for the duration of
        the private sale.

        @notice Sets the maximum a holder can hold for the duration of the private sale (1M Labz) or approximately ~1% of 
        circulating supply. 
        
        @notice That limit will be lifted after the private sale is over this is to guarantee a fair private sale 
        and the stability of the token after the lock period (90 days) is over.
     */
    uint256 public maxTotalAmountPerHoldersInLabz = 1000000 * 10 ** 18;

    constructor(
        address token,
        address _multisig,
        address authenticator,
        uint256 startPrice
    ) {
        labzTokenAddress = token;
        multisig = _multisig;
        _authenticator = authenticator;
        labzToken = Labz(token);
        countdown = startOn - block.timestamp;
        privateSaleStarted = false;
        privateSaleEnded = false;
        price = startPrice;
        chainID = block.chainid;
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(GLOBAL_ADMIN, msg.sender);
        _setupRole(UPDATER_ROLE, msg.sender);
        _setupRole(EMERGENCY_BREAK_ROLE, msg.sender);
        _setupRole(MULTISIG_ROLE, multisig);
             
    }



    /**
        @notice everyone can start the private sale if its time for it to start will revert if conditions are not met
     */
    function startPrivateSale() public nonReentrant emergencyNotEnabled returns (bool) {
        require(
            privateSaleEnded != true && privateSaleStarted != true,
            "sale cannot be started"
        );
        updateCountdown();
        require(countdown == 0, "you cannot start it yet");
        privateSaleStarted = true;
        privateSaleEnded = false;
        totalHolders = 0;
        totalETH = 0;
        totalMATICS = 0;
        daysLeft = (endsOn - block.timestamp) / 1 days;
        labzLeft = maxCirculatingSupply;
        return true;
    }

    
    function emergencyBreak(string memory reason) external payable override onlyRole(EMERGENCY_BREAK_ROLE) {
        require(emergencyBreakActivated != true, "already in emergency mode");
        emergencyBreakActivated = true;
        emergencyBreakActivationReason = reason;
        emit EmergencyBreakActivated(msg.sender, reason, block.timestamp);
    }

    function deactivateBreak() external override onlyRole(EMERGENCY_BREAK_ROLE) {
          require(emergencyBreakActivated == true, "not in emergency mode");
        emergencyBreakActivated = false;
        emit EmergencyBreakDeactivated(msg.sender, emergencyBreakActivationReason, true,  block.timestamp);
    }


    function updateCountdown() private {
        countdown = startOn - block.timestamp;
    }

    function buyQty(uint256 qty) external payable nonReentrant presaleStarted emergencyNotEnabled {
        require(msg.value > 0, "no zero amount");
        require(msg.sender != address(0), "no zero address");
        uint256 amount = getQuoteWithQty(qty);
        require(msg.value == amount, "you need to send the exact amount");
        labzToken.mintForPresale(msg.sender, qty);
        updateMintedQty(qty);
        updateTotalETH(amount);
        updateTotalHolders();
        updateDaysLeft();
        (bool sent, bytes memory data) = multisig.call{
            value: address(this).balance
        }("");
        require(sent, "failed to transfer ether / matics");
    }

    function buyWithEthers() external payable nonReentrant emergencyNotEnabled {
        require(msg.value > 0, "no zero amount");
        require(msg.sender != address(0), "no zero address");
        uint256 qty = getQuoteWithValueInETH(msg.value);

        labzToken.mintForPresale(msg.sender, qty);
        updateMintedQty(qty);
        updateTotalETH(msg.value);
        updateTotalHolders();
        updateDaysLeft();
        (bool sent, bytes memory data) = multisig.call{value: getBalance()}("");
        require(sent, "failed to transfer ether / matics");
    }

    function getQuoteWithQty(uint256 qty) public view emergencyNotEnabled returns (uint256) {
        return _calculateAmount(qty);
    }

    function getQuoteWithValueInETH(uint256 ethValue)
        public
        view emergencyNotEnabled
        returns (uint256)
    {
        return _calculateAmount(ethValue);
    }

    function _calculateAmount(uint256 qty) private view returns (uint256) {
        return qty.mulDiv(price, mantissa);
    }

    function _calculateAmountFromValue(uint256 value)
        private
        view
        returns (uint256)
    {
        return value.mulDiv(mantissa, price);
    }

    function updateMintedQty(uint256 qty) internal {
        labzMinted += qty;
        updateLabzLeft();
    }

    function updateTotalETH(uint256 qtyEth) internal {
        totalETH += qtyEth;
    }

    function updateTotalMATICS(uint256 qtyMatics) internal {
        totalMATICS += qtyMatics;
    }

    function updateTotalHolders() internal {
        totalHolders += 1;
    }

    function updateDaysLeft() internal {
        daysLeft = (endsOn - block.timestamp) / 1 days;
    }

    function updateLabzLeft() internal {
        labzLeft = maxCirculatingSupply - labzMinted;
    }



    modifier presaleStarted() {
        require(privateSaleStarted == true, "sale is not started");
        _;
    }

    modifier presaleEnded() {
        require(
            privateSaleEnded == true && privateSaleStarted == false,
            "sale has ended"
        );
        _;
    }

    // Function to receive Ether. msg.data must be empty
    receive() external payable {
        require(privateSaleStarted == true && emergencyBreakActivated != true, "cannot receive at this time");
    }

    // Fallback function is called when msg.data is not empty
    fallback() external payable {
        require(privateSaleEnded == true && emergencyBreakActivated != true, "cannot do that at this time");
    }

    function getBalance() public view emergencyNotEnabled returns (uint256) {
        return address(this).balance;
    }
}
