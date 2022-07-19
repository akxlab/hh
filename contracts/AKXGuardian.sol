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




contract AKXGuardian is Initializable, UUPSUpgradeable, RBAC {

    using LibSignature for bytes32;

    address public routerImplementation;
    AKXEcosystemRouter private _akxRouter;

    address public repositoryImplemnentation;
    ResourcesRepository private _repository;

    address public resolverImplementation;
    AKXResolver private _resolver;

    function initialize(
        address _routerImplemnentation,
        address _repoImplementation,
         address _resolverImplementation
    ) public initializer {
        __RBAC_init(msg.sender);
        __AKXGuardian_init(_routerImplemnentation, _repoImplementation, _resolverImplementation);
    }

    function __AKXGuardian_init(    
        address _routerImplemnentation,
        address _repoImplementation,
        address _resolverImplementation) public onlyInitializing nonReentrant {
            repositoryImplemnentation = _repoImplementation;
            resolverImplementation = _resolverImplementation;
            routerImplementation = _routerImplemnentation;
            _akxRouter = AKXEcosystemRouter(routerImplementation);
            _repository = ResourcesRepository(repositoryImplemnentation);
            _resolver = AKXResolver(resolverImplementation);
        }

    function _authorizeUpgrade(address newImplementation) internal onlyRole(BaseRoles.GLOBAL_ADMIN_ROLE)  override {}

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