pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts-upgradeable/utils/introspection/ERC165StorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./IAKXResolver.sol";
import "./repositories/ResourcesRepository.sol";
import "./repositories/entities/Resource.sol";
import "./utils/LibSignature.sol";

abstract contract AKXResolverBase is IAKXResolver, ERC165StorageUpgradeable {

    bytes4 internal INTERFACE_ID;

       address public adminAuthorized;
  

    function __AKXResolverBase_init(bytes4 interfaceId, address admin) public onlyInitializing {
        INTERFACE_ID = interfaceId;
        _registerInterface(interfaceId);
        adminAuthorized = admin;
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
    mapping(bytes32 => bytes32) private hashes;
    mapping(bytes32 => bytes) private signatures;
    mapping(bytes32 => address) private signers;
    mapping(address => bytes32) private addrToResID;
    mapping(string => bytes32) private stringsToResID;
    

    ResourcesRepository private rr;
      using LibSignature for bytes32;

 

    struct SetupContentRequest {
        string name;
        string types;
        address addr;
        address owner;
        bytes32 signature;
    }

    constructor() {
        _disableInitializers();
    }

    function initialize(ResourcesRepository r, address defaultAdmin) public initializer onlyInitializing {
      
        rr = r;
        __AKXResolverBase_init(bytes4(keccak256(abi.encodePacked("authorized(bytes32, address)"))), defaultAdmin);
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

    function setContentHash(bytes32 contentId, bytes32 hash) public onlyAuthorized(msg.sender) {
        hashes[contentId] = hash;
    }

    function contentHash(bytes32 contentId) external nonReentrant returns (bytes32) {
        return hashes[contentId];
    }

    function resolveContent(bytes32 contentId) internal returns(Resource.ResourceRecord memory) {
        return rr.getResource(contentId);
    }

    function resolveContentType(bytes32 id) internal returns(string memory) {
        return rr.getResourceTypeAsString(id);
    }

    function setupContent(bytes calldata data, bytes32 hash) external nonReentrant onlyAuthorized(msg.sender) {
       SetupContentRequest memory scr = abi.decode(data, (SetupContentRequest));
       bytes memory sig = abi.encode(scr.signature);
       address signer = hash.recover(sig);
       assert(signer == scr.owner);
       bytes32 rid = rr.initResource(
       scr.name, scr.types, scr.addr, data
        );
    
        setContentHash(rid, hash);
        signatures[rid] = sig;

    }

    function validateSignature(bytes32 id) public nonReentrant returns(bool) {
        bytes memory sig = signatures[id];
        address signer = signers[id];
        bytes32 hash = hashes[id];
        if(hash.recover(sig) == signer) {
            return true; 
        }
        return false;
       
    }

    /**
        resolve functions supporting many input types
     */

    function resolve(address addr) public nonReentrant returns(bytes memory) {
        bytes32 id = addrToResID[addr];
        assert(validateSignature(id) == true);
        string memory ct = resolveContentType(id);
        
        Resource.ResourceRecord memory _rr = resolveContent(id);
        return abi.encode(_rr);     
    }

    function resolve(string memory str) public nonReentrant returns (bytes memory) {
         bytes32 id = stringsToResID[str];
        assert(validateSignature(id) == true);
        string memory ct = resolveContentType(id);
        
        Resource.ResourceRecord memory _rr = resolveContent(id);
        return abi.encode(_rr);     
   
    }

    /*
    function resolve(bytes calldata data) public onlyAuthorized(msg.sender) {}
    */

    function resolve(bytes32 id) public nonReentrant returns(bytes memory) {
         assert(validateSignature(id) == true);
        string memory ct = resolveContentType(id);
        
        Resource.ResourceRecord memory _rr = resolveContent(id);
        return abi.encode(_rr);     
    }


      modifier onlyAuthorized(address _sender) {
        require(_sender == adminAuthorized || authorized(keccak256(addressToBytes(_sender)), _sender) == true, "unauthorized");
        _;
    }

}