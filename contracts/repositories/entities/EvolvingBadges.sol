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

interface IAKXBadgesMetadata {

    // 2 badge genders (sorry no 3rd gender exists in ape world as far as we know!)
    enum BadgesGenders {
        MALE,
        FEMALE
    }

    // 8 badge types / classes
    enum BadgesType {
        DEFAULT,
        OGS,
        FOUNDERS,
        CODERZ,
        MUTANTS,
        DAO,
        INFLUENCERS,
        SPECIAL
    }

    enum BadgesUsage {
        TRADE,
        EXCHANGE,
        PRIVATE_SALE_ACCESS,
        REWARD,
        AUTH_PASS,
        VOTING,
        LEVEL,
        GAMING,
        SPECIAL_ARENA
    }

    struct Badge {
        address owner;
        Animated animationData;
        BadgesType[] types;
        BadgesUsage[] usage;
        uint256[] layerImageIndexes;
        string[] images; // images in order of layers
        uint256 evolutionLevel;
        string merkleHexRoot;
        string hash;
        bytes signature;
    }

    struct Animated {
        bool isAnimated;
        uint[] timeframe;
        string[] animationsCode;
        uint duration;
        bool loop;
    }




    event NewBadgeAssigned(address indexed _owner, uint256 _badgeId);
    event BadgeUpdated(address indexed _owner, uint256 badgeId);
    event BadgeTraded(address indexed origOwner, address indexed newOwner, uint256 badgeId);

    function isSellable() external returns(bool);
    function isBuyable() external returns(bool);
    function isExchangeable() external returns(bool);
    function canEvolve() external returns(bool);
    function canLevelUp() external returns(bool);
    function useBadgeForAccess(uint256 badgeID) external;
    function issueRoadMapBadge() external;
    function swapBadgeToChain(uint256 chainID) external;




}

abstract contract AKXBadges is IAKXBadgesMetadata, ERC721URIStorage {

    // tokenId => nft address
    mapping(uint256 => address) private _badgesIndexes;
    // tokenId => currentBadgeLevel (only informational)
    mapping(uint256 => uint8) private _badgeLevelsIndexes;
    // tokenId => [time(whenlevelup) => level (uint8 1-10)]
    mapping(uint256 => mapping(uint256 => uint8)) private _badgeUpcomingLevelUps;
    // tokenId => [owner => badge details]
    mapping(uint256 => mapping(address => Badge)) private _badgeIdToOwnerToDetails;

    bytes32 internal MerkleRoot;
    bool public activateMutations = false;
   


    uint8[] levels = [1,2,3,4,5,6,7,8,9,10];



    function isSellable() external virtual returns(bool);
    function isBuyable() external virtual returns(bool);
    function isExchangeable() external virtual returns(bool);
    function canEvolve() external virtual returns(bool);
    function canLevelUp() external virtual returns(bool);
    function useBadgeForAccess(uint256 badgeID) external virtual;
    function issueRoadMapBadge() external virtual;
    function swapBadgeToChain(uint256 chainID) external virtual;



}