// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/metatx/MinimalForwarder.sol";
import "@openzeppelin/contracts/metatx/ERC2771Context.sol";

abstract contract Badges is
    AccessControlEnumerable,
    Pausable,
    ERC721URIStorage,
    ERC2771Context
{
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant TEMPLATER_ROLE = keccak256("TEMPLATER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    event NewBadge(address indexed to, uint256 tokenId);

    using MerkleProof for bytes32[];
    uint256 public templateIds;
    string public baseTokenURI;
    bytes32[] private roots;

    struct BadgeTemplate {
        string name;
        string description;
        string usage;
        string image;
        uint256 value;
    }

    mapping(uint256 => BadgeTemplate) public templates;
    mapping(uint256 => uint256) public templateQty;

    event BadgeActivated(uint256 indexed tokenId, uint256 indexed templateId);

    constructor(string memory __name, string memory __symbol, MinimalForwarder fwd, address multisig)
        ERC2771Context(address(fwd))
        ERC721(__name, __symbol)
    {
        require(multisig != address(0), "AKX/invalid-multisig-address");

        _setupRole(DEFAULT_ADMIN_ROLE, multisig);

        _setupRole(ADMIN_ROLE, multisig);
        _setupRole(TEMPLATER_ROLE, multisig);
        _setupRole(PAUSER_ROLE, multisig);
    }

    /// @notice Cast to uint96
    /// @dev Revert on overflow
    /// @param x Value to cast
    function toUint96(uint256 x) internal pure returns (uint96 z) {
        require((z = uint96(x)) == x, "AKX/uint96-overflow");
    }

    /// @notice Set the baseURI
    /// @dev Update the baseURI specified in the constructor
    /// @param baseURI New baseURI
    function setBaseURI(string calldata baseURI) external {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "AKX/only-def-admin"
        );
        baseTokenURI = baseURI;
    }

    /// @notice Set Merkle Tree Root Hashes array
    /// @dev Called by admin to update roots for different address batches by templateId
    /// @param _roots Root hashes of the Merkle Trees by templateId
    function setRootHashes(bytes32[] calldata _roots) external whenNotPaused {
        require(hasRole(ADMIN_ROLE, _msgSender()), "AKX/only-admin");
        roots = _roots;
    }

    /// @dev Templates

    /// @notice Create a new template
    /// @dev Access restricted to only Templaters
    /// @param name The name of the new template
    /// @param description A description of the new template
    /// @param image A filename of the new template
    function createTemplate(
        string calldata name,
        string calldata description,
        string calldata image,
        uint256 value
    ) external whenNotPaused {
        require(hasRole(TEMPLATER_ROLE, _msgSender()), "AKX/only-templater");

        uint256 id = templateIds++;

        templates[id].name = name;
        templates[id].description = description;
        templates[id].image = image;
        templates[id].value = value;
    }

    function activateBadge(
        bytes32[] calldata proof,
        uint256 templateId,
        string calldata tokenURI
    ) external whenNotPaused returns (bool) {
        require(templateIds > templateId, "AKX/invalid-template-id");
        require(
            proof.verify(
                roots[templateId],
                keccak256(abi.encodePacked(_msgSender()))
            ),
            "AKX/only-redeemer"
        );

        uint256 _tokenId = _getTokenId(_msgSender(), templateId);

        /// @dev Increase the quantities
        templateQty[templateId] += 1;

        require(
            _mintWithTokenURI(_msgSender(), _tokenId, tokenURI),
            "AKX/badge-not-minted"
        );

        emit BadgeActivated(_tokenId, templateId);
        return true;
    }

    function getBadgeRedeemer(uint256 tokenId)
        external
        view
        returns (address redeemer)
    {
        require(_exists(tokenId), "AKX/invalid-token-id");
        (redeemer, ) = _unpackTokenId(tokenId);
    }

    function getBadgeTemplate(uint256 tokenId)
        external
        view
        returns (uint256 templateId)
    {
        require(_exists(tokenId), "AKX/invalid-token-id");
        (, templateId) = _unpackTokenId(tokenId);
    }

    /// @notice Getter function for tokenId associated with redeemer and templateId
    /// @dev Check if the templateId exists
    /// @dev Check if the tokenId exists
    /// @param redeemer Redeemer address
    /// @param templateId Template Id
    /// @return tokenId Token Id associated with the redeemer and templateId
    function getTokenId(address redeemer, uint256 templateId)
        external
        view
        returns (uint256 tokenId)
    {
        require(templateIds > templateId, "AKX/invalid-template-id");
        tokenId = _getTokenId(redeemer, templateId);
        require(_exists(tokenId), "AKX/invalid-token-id");
    }

    /// @notice ERC721 _transfer() Disabled
    /// @dev _transfer() has been overriden
    /// @dev reverts on transferFrom() and safeTransferFrom()
    function _transfer(
        address,
        address,
        uint256
    ) internal pure override {
        revert("AKX/token-transfer-disabled");
    }

    /// @notice Generate tokenId
    /// @dev Augur twist by concatenate redeemer and templateId
    /// @param redeemer Redeemer Address
    /// @param templateId Template Id
    /// @param _tokenId Token Id
    function _getTokenId(address redeemer, uint256 templateId)
        private
        pure
        returns (uint256 _tokenId)
    {
        bytes memory _tokenIdBytes = abi.encodePacked(
            redeemer,
            toUint96(templateId)
        );
        assembly {
            _tokenId := mload(add(_tokenIdBytes, add(0x20, 0)))
        }
    }

    /// @notice Unpack tokenId
    /// @param tokenId Token Id of the Badge
    /// @return redeemer Redeemer Address
    /// @return templateId Template Id
    function _unpackTokenId(uint256 tokenId)
        private
        pure
        returns (address redeemer, uint256 templateId)
    {
        assembly {
            redeemer := shr(
                96,
                and(
                    tokenId,
                    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF000000000000000000000000
                )
            )
            templateId := and(
                tokenId,
                0x0000000000000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFF
            )
        }
    }

    /// @notice Mint new token with tokenURI
    /// @dev Automatically concatenate baseURI with tokenURI via abi.encodePacked
    /// @param to Owner of the new token
    /// @param tokenId Token Id of the Baddge
    /// @param tokenURI Token URI of the Badge
    /// @return True if the new token is minted
    function _mintWithTokenURI(
        address to,
        uint256 tokenId,
        string calldata tokenURI
    ) private returns (bool) {
        _mint(to, tokenId);
        _setTokenURI(tokenId, tokenURI);
        return true;
    }

    /// @notice Getter function for baseTokenURI
    /// @dev Override _baseURI()
    function _baseURI() internal view override returns (string memory) {
        return baseTokenURI;
    }

    function version() public pure returns (string memory) {
        return "v1";
    }

    /// @notice Pause all the functions
    /// @dev the caller must have the 'PAUSER_ROLE'
    function pause() external {
        require(hasRole(PAUSER_ROLE, _msgSender()), "AKX/only-pauser");
        _pause();
    }

    /// @notice Unpause all the functions
    /// @dev the caller must have the 'PAUSER_ROLE'
    function unpause() external {
        require(hasRole(PAUSER_ROLE, _msgSender()), "AKX/only-pauser");
        _unpause();
    }

    function _msgSender()
        internal
        view
        virtual
        override(Context, ERC2771Context)
        returns (address sender)
    {
        return super._msgSender();
    }

    function _msgData()
        internal
        view
        virtual
        override(Context, ERC2771Context)
        returns (bytes calldata)
    {
        return super._msgData();
    }

    /// @notice IERC165 supportsInterface
    /// @dev supportsInterface has been override
    function supportsInterface(bytes4 interfaceId)
        public
        view
        virtual
        override(AccessControlEnumerable, ERC721)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
