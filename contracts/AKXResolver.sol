pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165StorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./IAKXResolver.sol";
import "./repositories/ResourcesRepository.sol";
import "./repositories/entities/Resource.sol";

abstract contract AKXResolverBase is IAKXResolver, ERC165StorageUpgradeable {

    bytes4 internal INTERFACE_ID;

    function __AKXResolverBase_init(bytes4 interfaceId) public onlyInitializing {
        INTERFACE_ID = interfaceId;
        _registerInterface(interfaceId);
    }

     function bytesToAddress(bytes memory b) internal pure returns(address payable a) {
        require(b.length == 20);
        assembly {
            a := div(mload(add(b, 32)), exp(256, 12))
        }
    }

    function addressToBytes(address a) internal pure returns(bytes memory b) {
        b = new bytes(20);
        assembly {
            mstore(add(b, 32), mul(a, exp(256, 12)))
        }
    }


}

contract AKXResolver is Initializable, AKXResolverBase, ReentrancyGuardUpgradeable {

    mapping(bytes32 => mapping(address => bool)) private _hashAuth;
    mapping(bytes32 => bytes) private hashes;

    ResourcesRepository private rr;

    constructor() {
        _disableInitializers();
    }

    function initialize(ResourcesRepository r) public initializer onlyInitializing {
        rr = r;
        __AKXResolverBase_init(bytes4(keccak256(abi.encodePacked("authorized(bytes32, address)"))));
    }

      /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view override returns (bool) {
        return super.supportsInterface(interfaceId) == true;
    }

    function isAuthorized(bytes32 hash, address addr) public nonReentrant returns(bool) {
        return _hashAuth[hash][addr] == true;
    }


      function authorized(bytes32 hash, address addr) public override nonReentrant returns(bool) {
        return isAuthorized(hash, addr);
    }

    function setContentHash(bytes32 contentId, bytes calldata hash) external onlyAuthorized(msg.sender) {
        hashes[contentId] = hash;
    }

    function contentHash(bytes32 contentId) external nonReentrant returns (bytes memory) {
        return hashes[contentId];
    }

    function resolveContent(bytes32 contentId) internal returns(Resource.ResourceRecord memory) {
        return rr.getResource(contentId);
    }

    function resolveContentType(bytes32 id) internal returns(string memory) {
        return rr.getResourceTypeAsString(id);
    }

      modifier onlyAuthorized(address _sender) {
        require(authorized(keccak256(addressToBytes(_sender)), _sender) == true, "unauthorized");
        _;
    }

}