pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "./repositories/ResourcesRepository.sol";
import "./utils/acl/RBAC.sol";
import "./AKXEcosystemRouter.sol";
import "./utils/ERC1271.sol";
import "./utils/LibSignature.sol";
import "./AKXResolver.sol";
import "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";
import "@openzeppelin/contracts-upgradeable/proxy/beacon/IBeaconUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


// @dev no worry about the beacon name ;) we just loooove canadian bacon !!!! 

contract AKXBaconMmmBaaaacon is BeaconProxy, Ownable {

   
    constructor(address beacon, bytes memory data) BeaconProxy(beacon, data) {



    }

     /**
     * @dev Returns the current beacon address.
     */
    function _beacon() internal view virtual override returns (address) {
        return _getBeacon();
    }

 
}

contract AKXBeaconsRepository {

    mapping(address => UpgradeableBeacon) public _uBeacons;
    mapping(uint => address) public beaconsss;

    constructor(address[3] memory beacons) {

        for(uint256 j = 0; j < beacons.length; j++) {
            _uBeacons[beacons[j]] = new UpgradeableBeacon(beacons[j]);
            beaconsss[j] = beacons[j];
        }

    }

}


contract AKXGuardian is Initializable, UpgradeableBeacon, RBAC {

    using LibSignature for bytes32;

    address public routerImplementation;
    AKXEcosystemRouter private _akxRouter;

    address public repositoryImplemnentation;
    ResourcesRepository private _repository;

    address public resolverImplementation;
    AKXResolver private _resolver;

 /*   function initialize(
        address _routerImplementation,
        address _repoImplementation,
         address _resolverImplementation
    ) public initializer {
        __RBAC_init(msg.sender);
        __AKXGuardian_init(_routerImplementation, _repoImplementation, _resolverImplementation);
    } */

    constructor(address beaconsRepo) UpgradeableBeacon(beaconsRepo) {
            AKXBeaconsRepository br = AKXBeaconsRepository(beaconsRepo);
            __AKXGuardian_init(br.beaconsss(0), br.beaconsss(1),  br.beaconsss(2));
         }

    function __AKXGuardian_init(    
        address _routerImplemnentation,
        address _repoImplementation,
        address _resolverImplementation) internal {
            repositoryImplemnentation = _repoImplementation;
            resolverImplementation = _resolverImplementation;
            routerImplementation = _routerImplemnentation;
            _akxRouter = AKXEcosystemRouter(routerImplementation);
            _repository = ResourcesRepository(repositoryImplemnentation);
            _resolver = AKXResolver(resolverImplementation);
        }


    function supportsInterface(bytes4 interfaceID) public view override returns(bool) {
        return super.supportsInterface(interfaceID);
    }

    function getResolver() internal nonReentrant returns(AKXResolver) {
        return _resolver;
    }

    function callResolver(address addr) public nonReentrant returns(bytes memory) {
        return getResolver().resolve(addr);
    }

    function callResolver(string memory str) public nonReentrant returns(bytes memory) {
        return getResolver().resolve(str);
    }

    function callResolver(bytes32 id) public nonReentrant returns(bytes memory) {
        return getResolver().resolve(id);
    }

    function processRouterRequest(bytes calldata data) external {
        // todo processing

       // _akxRouter.callback(response);

    }

   receive() external payable {
       revert("cannot send value to this contract");
    }


}