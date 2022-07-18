pragma solidity 0.8.15;

// SPDX-License-Identifier: GPL-3.0-only


import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/presets/ERC20PresetMinterPauser.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "./Lock.sol";
import "../utils/acl/RBAC.sol";



abstract contract BaseSafeERC20 is Lock, RBAC {

    using Math for uint256;

    event Deposit(address indexed from, address indexed to, uint256 amount);

    address public erc20Operator;

    bytes32 public constant RBAC_BASE_SAFEERC20 =  keccak256("BaseSafeERC20(uint256 unlockTime)");

    constructor(uint256 _unlockTime) Lock(_unlockTime)  RBAC() {
        addPermission("ERC20_OPERATOR", RBAC_BASE_SAFEERC20);
        grant(RBAC_BASE_SAFEERC20, _permissions["ERC20_OPERATOR"], msg.sender);
        unlockTime = _unlockTime;
        erc20Operator = msg.sender;
    }

    function _safeCall(IERC20 token, bytes memory data) private {        
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "ERC20: call failed");

        if (returndata.length > 0) {

            require(abi.decode(returndata, (bool)), "ERC20: operation did not succeed");
        }
    }

    function _safeTransfer(IERC20 token, address to, uint256 value) private {
        _safeCall(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

     function _safeTransferFrom(IERC20 token, address from, address to, uint256 value) private {
        _safeCall(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

     function mintERC20(address tokenAddress, address recipient, uint256 amount) internal {
        ERC20PresetMinterPauser erc20 = ERC20PresetMinterPauser(tokenAddress);
        erc20.mint(recipient, amount);
    }

     function burnERC20(address tokenAddress, address owner, uint256 amount) internal {
        ERC20Burnable erc20 = ERC20Burnable(tokenAddress);
        erc20.burnFrom(owner, amount);
    }



    modifier onlyOperator() {
        require(msg.sender == erc20Operator, "akx-erc20/access-denied");
        _;
    }
    
    receive() payable external nonReentrant {
        require(msg.sender != address(0), "akx-erc20/no-zero-address-receive");
        require(msg.value > 0, "akx-erc20/deposit-too-small");
        emit Deposit(msg.sender, address(this), msg.value);
    }


}