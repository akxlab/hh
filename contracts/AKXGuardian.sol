pragma solidity 0.8.15;

// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "./repositories/ResourcesRepository.sol";
import "./utils/acl/RBAC.sol";
import "./AKXEcosystemRouter.sol";
import "./utils/ERC1271.sol";
import "./utils/LibSignature.sol";




contract AKXGuardian is Initializable, UUPSUpgradeable, RBAC, ERC1271 {

    using LibSignature for bytes32;

    address public routerImplementation;
    AKXEcosystemRouter private AKXRouter;

    address public repositoryImplemnentation;
    ResourcesRepository private Repository;

    bool private returnSuccessfulValidSignature;

    function setReturnSuccessfulValidSignature(bool value) public {
        returnSuccessfulValidSignature = value;
    }

    function isValidSignature(bytes32 _hash, bytes memory _signature) public override view  returns (bytes4) {
        return returnSuccessfulValidSignature ? ERC1271_RETURN_VALID_SIGNATURE : ERC1271_RETURN_INVALID_SIGNATURE;
    }

    function initialize(
        address _routerImplemnentation,
        address _repoImplementation
    ) public initializer {
        __RBAC_init(msg.sender);

    }

    function __AKXGuardian_init(    
        address _routerImplemnentation,
        address _repoImplementation) public ifNotInitialized nonReentrant {

            routerImplementation = _routerImplemnentation;
            repositoryImplemnentation = _repoImplementation;
            AKXRouter = AKXEcosystemRouter(routerImplementation);
            Repository = ResourcesRepository(repositoryImplemnentation);



        }

    function _authorizeUpgrade(address newImplementation) internal onlyRole(BaseRoles.GLOBAL_ADMIN_ROLE)  override {}

    function supportsInterface(bytes4 interfaceID) public view override returns(bool) {
        return super.supportsInterface(interfaceID);
    }

}