// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";


contract UsersFactory is ERC721URIStorage, ERC721Enumerable, AccessControlEnumerable {

    // owner is usersregistry contract
    address public usersRegistry;

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    bytes32 public constant FACTORY_OPERATOR_ROLE = keccak256("FACTORY_OPERATOR_ROLE");

    event NewUserCreated(address indexed UserContract);

    constructor(string memory name_, string memory symbol_, address usersRegistryContract) ERC721(name_, symbol_) {
        usersRegistry = usersRegistryContract;
        _setupRole(FACTORY_OPERATOR_ROLE, usersRegistry);
    }

    function mint(address receiver, string memory tokenURIData) external onlyRole
    (FACTORY_OPERATOR_ROLE) returns (uint256) {
        uint256 newItemId = _tokenIds.current();
        _safeMint(receiver, newItemId);
        _setTokenURI(newItemId, tokenURIData);

        _tokenIds.increment();

        return newItemId;
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721Enumerable, AccessControlEnumerable) returns (bool) {
        return super.supportsInterface(interfaceId);
    }


}