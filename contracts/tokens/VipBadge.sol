// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./Badges.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";

contract VipBadge is Badges {

    constructor(string memory uri, string memory image, MinimalForwarder fwd, address multisig) Badges("AKX Vip Badge", "AKX.VBA", fwd, multisig) {

       setURI(uri);
       setTemplate(image);

    }

    function setURI(string memory uri) internal  {
        
        this.setBaseURI(uri);

    }

    function setTemplate(string memory image) internal {
        this.createTemplate("AKX Vip Badge Template", "Badge to authenticate private sale", image, 0);
    }


}