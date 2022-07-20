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
 
/**
    @title AKX Emergency Break
    @notice to be included in contracts in need of an emergency break
    @dev might eventually become an EIP proposal
    @author AKX Labs <info@akxlab.com>
 */

import "./draft-IEmergencyBreak.sol";

abstract contract EmergencyBreak is IEmergencyBreak  {

   

    bool public emergencyBreakActivated;
    string public emergencyBreakActivationReason;


    /**
        @notice this function is in case something really wrong happens like a hack or a zero-day exploit
        to be able to stop all damage that could have been caused by it and keep your funds secured. It
        should never be used as a way to manipulate market. 

        @notice Emergency Break Procedure:

        Only one of the AKX team member can activate the emergency break.

        The WHY / REASON needs to be given as to why it is activated. For transparency and prevent abuse.

        @dev emergencyBreak() 
        @dev refer to the notice for the description
        @param reason string !important and required



     */

    function emergencyBreak(string memory reason) external virtual override {}
    function deactivateBreak() external virtual override {}

    modifier emergencyNotEnabled() {
        require(emergencyBreakActivated != true, "cannot do that while in emergency mode");
        _;
    }

 }