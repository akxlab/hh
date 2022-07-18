pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT

import "./interface/IBaseSafeERC20Configurator.sol";

abstract contract BaseSafeERC20Configurator is IBaseSafeERC20Configurator {

  /**
        @notice initialize the new erc20 token parameters
        @param tokenInfo TokenInfo abi.encoded struct
        @param options ERC20Options that defines what the token can do
     */

    function initialize(bytes calldata tokenInfo, bytes calldata options) external virtual override;
    function decodeOptions() external override returns(ERC20Options memory) {}
    function decodeTokenInfo() external override returns(TokenInfo memory) {}


}