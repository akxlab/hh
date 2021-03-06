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

 interface IEmergencyBreak {
    event EmergencyBreakActivated(address indexed from, string reason, uint256 when);
    event EmergencyBreakDeactivated(address indexed from, string reason, bool problemFixed, uint256 when);

    function emergencyBreak(string memory reason) external;
    function deactivateBreak() external;

 }