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
    @title AKX PRIVATE SALE ROLE MANAGER
    @notice will only be used for the private sale, RBAC (resource based access control)
    will be used after in all other contracts
    @author AKX Labs <info@akxlab.com>
 */



 abstract contract AKXPsACL  {

    bytes32 public constant PRIVATE_SALE_ROLE = keccak256("PRIVATE_SALE_ROLE");
    bytes32 public constant EMERGENCY_BREAK_ROLE = keccak256("EMERGENCY_BREAK_ROLE");
    bytes32 public constant GLOBAL_ADMIN = keccak256("GLOBAL_ADMIN");
    bytes32 public constant UPDATER_ROLE = keccak256("UPDATER_ROLE");
    bytes32 public constant MULTISIG_ROLE = keccak256("MULTISIG_ROLE");
    bytes32 public constant VERIFIED_HOLDER_ROLE = keccak256("VERIFIED_HOLDER_ROLE");

    event RoleGranted(address indexed _to, address indexed _by, bytes32 roleID);
    event RoleRevoked(address indexed _to, address indexed _by, bytes32 roleID);

/*
    function grantAccess(bytes32 role, address _to) public  {
        _grantRole(role, _to);
    }

    function revokeAccess(bytes32 role, address _to) public  {
        _revokeRole(role, _to);
    }
*/
    

 }