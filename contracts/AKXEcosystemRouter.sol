pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./repositories/ResourcesRepository.sol";

abstract contract AKXRoutes is Initializable, OwnableUpgradeable, ReentrancyGuardUpgradeable {

    mapping(string => mapping(address => bool)) public isValidAKXRoute;
    mapping(bytes32 => string) public routeIDToName;
    mapping(string => bytes32) public routeNameToHashes;
    mapping(string => bytes32) public routeNameToID;
    mapping(bytes32 => AKXRoute) public routeIDToData;

    bytes32[] hashes;



    struct AKXRoute {
        string routeName;
        bytes32 id;
        address routeContract;
        bool needAuth;
        bool needValidUser;
       
    }

    struct AKXRouteParams {
        bytes []keys;
        bytes []values;
        bytes4 interfaceId;
        bytes32 funcSignature;
    }

    bool internal setup;

    function __Route_init() public view onlyOwner  {
        require(setup != true, "already setup");

    }

    function _addRoute(address routerAddress, string memory name, address destContract, bool auth, bool user) internal virtual  {}

    function addRoute(address routerAddress, string memory name, address destContract, bool auth, bool user) public nonReentrant onlyOwner returns(bytes32) {
        bytes32 routeID = keccak256(abi.encode(name, routerAddress));
        AKXRoute memory route = AKXRoute(name, routeID, destContract, auth, user);
        routeIDToName[routeID] = route.routeName;
        routeIDToData[routeID] = route;
        routeNameToID[route.routeName] = routeID;
        bytes32 routeHash = sha256(abi.encode(routeID));
        routeNameToHashes[route.routeName] = routeHash;
        hashes.push(routeHash);
        return routeID;


    }


}

contract AKXEcosystemRouter is Initializable, UUPSUpgradeable, AKXRoutes {

    mapping(address => mapping(bytes32 => string)) private _routers;
    mapping(bytes32 => AKXRoute) private _routes;
    mapping(bytes32 => AKXRouteParams) private _routeParams;
    mapping(uint256 => address) private _routerIndexes;

    uint256 internal _indexes;

    bytes32 public merkleRoot;

    ResourcesRepository internal repo;

    constructor() {
        _disableInitializers();
    }

    function initialize(address resourcesRepo, address[] memory ecosystemRouters) public initializer {
        _indexes = 0;
        repo = ResourcesRepository(resourcesRepo);
        for(uint j = 0;  j < ecosystemRouters.length; j++) {
            
            _routerIndexes[_indexes] = ecosystemRouters[j];
            _indexes += 1;
        }
        __Ownable_init();
        __Route_init();
        __Context_init();
        __UUPSUpgradeable_init();

    }

    function _addRoute(address routerAddress, string memory name, address destContract, bool auth, bool user) internal override {
        addRoute(routerAddress, name, destContract, auth, user);
    }

    function _safeCall(address contractAddress, bytes memory data) private {        
        (bool success, bytes memory returndata) = address(contractAddress).call(data);
        require(success, "AKXEcosystemRouter: call failed");

        if (returndata.length > 0) {

            require(abi.decode(returndata, (bool)), "AKXEcosystemRouter: operation did not succeed");
        }
    }

    function callRoute(string memory routeName, bytes memory data) private {
       AKXRoute memory  r = routeIDToData[routeNameToID[routeName]];
       _safeCall(r.routeContract, data);
    }

    function setMerkleRoot(bytes calldata data) public onlyOwner {
        merkleRoot = abi.decode(data, (bytes32));
    }

    function getMerkleRoot() external nonReentrant returns(bytes32) {
        return merkleRoot;
    }

    function getRoutesHashes() external nonReentrant returns(bytes32[] memory) {
        return hashes;
    }

    function getResourceIDFromRepository(address addr) public nonReentrant returns(bytes32) {
        require(repo.isValidResource(addr) == true, "invalid resource address");
        return repo.getResourceID(addr);
    }



    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}

    modifier onlyContract() {
        require(isContract(msg.sender) == true, "only contracts can call");
        _;
    }

    function isContract(address addr) public nonReentrant returns (bool) {
    uint size;
    assembly { size := extcodesize(addr) }
    return size > 0;
    }

}
