// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC721/presets/ERC721PresetMinterPauserAutoId.sol";

contract UserNFT is ERC721PresetMinterPauserAutoId {
    string public constant TOKEN_URI = "https://akxlab.com/api/v1/users/nft/";
    using Counters for Counters.Counter;
    Counters.Counter private id;

    mapping(address => uint256) private usersTokenIds;
    mapping(address => bool) private _hasNft;

    constructor()
        ERC721PresetMinterPauserAutoId("AKXUserNft", "AKXU", TOKEN_URI)
    {}

    function mintUserNFT(address to) public virtual {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "ERC721PresetMinterPauserAutoId: must have minter role to mint"
        );
        usersTokenIds[to] = id.current();
        id.increment();
        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        super._mint(to, id.current());
    }

    function getMyUserNFTId() public view returns (uint256) {
        return getUserNFTId(msg.sender);
    }

    function getUserNFTId(address user) public view returns (uint256) {
       // require(_hasNft[user] == true, "user has no nft");
        return usersTokenIds[user];
    }

// grant minter role to user factory
    function grantMinterRole(address c) public onlyRole(DEFAULT_ADMIN_ROLE) {
        grantRole(MINTER_ROLE, c);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override(ERC721PresetMinterPauserAutoId) {
        super._beforeTokenTransfer(from,to,tokenId);
    }
}

contract UserFactory {
    struct RegistrationRequest {
        uint256 reqId;
        address owner;
        bool isReferral;
        string referralCode;
        bytes signature;
    }

    struct RegistrationResponse {
        uint256 reqId;
        uint256 userNftTokenID;
        bytes signature;
    }

    enum RegTypes {
        DEFAULT,
        VIP_PRIVATE_SALE,
        CUSTOM,
        NO_NFT
    }

    RegTypes public defaultRegistrationType;

    mapping(RegTypes => bool) private _allowedRegistrationTypes;
    mapping(uint256 => RegistrationRequest) private _requests;
    mapping(uint256 => bool) private _processedRequests;
    mapping(uint256 => uint256) private _nonces;
    mapping(address => address) private _referreesToReferrerAddress;
    mapping(string => address) private _refCodeToRefferrer;
    mapping(address => string) private _addrToRefCode;
    mapping(string => bool) private _validCodes;
    mapping(address => bool) private _isUser;
    mapping(address => mapping(uint256 => address)) private _userReferrees;
    mapping(address => uint256) private _numReferrees;

    using Counters for Counters.Counter;
    Counters.Counter private nonce;

    address public userNftContract;
    UserNFT private _nftFactory;

    constructor(address nftContractAddress) {
        defaultRegistrationType = RegTypes.DEFAULT;
        _allowedRegistrationTypes[RegTypes.DEFAULT] = true;
        _allowedRegistrationTypes[RegTypes.VIP_PRIVATE_SALE] = true;
        userNftContract = nftContractAddress;
        _nftFactory = UserNFT(nftContractAddress);
    }

    function manuallyRegisterNewUser(uint256 reqId, address _for, bool isReferral, string memory referralCode) public returns (RegistrationResponse memory) {
         _requests[reqId] = RegistrationRequest(reqId, _for, isReferral, referralCode, abi.encode(""));
        _nonces[nonce.current()] = reqId;

        if (isReferral) {
            RegistrationResponse memory _res = registerWithReferralCode(
                nonce.current(),
                _requests[reqId]
            );
            _processedRequests[reqId] = true;
            nonce.increment();
            return _res;
        }

        RegistrationResponse memory res = register(nonce.current(),   _requests[reqId]);
        _processedRequests[reqId] = true;
        nonce.increment();
        return res;
    }

    function requestReceiver(bytes calldata data)
        public 
        returns (RegistrationResponse memory)
    {
        RegistrationRequest memory rr = abi.decode(data, (RegistrationRequest));
        _requests[rr.reqId] = rr;
        _nonces[nonce.current()] = rr.reqId;

        if (rr.isReferral) {
            RegistrationResponse memory _res = registerWithReferralCode(
                nonce.current(),
                rr
            );
            _processedRequests[rr.reqId] = true;
            nonce.increment();
            return _res;
        }

        RegistrationResponse memory res = register(nonce.current(), rr);
        _processedRequests[rr.reqId] = true;
        nonce.increment();
        return res;
    }

    function registerWithReferralCode(
        uint256 _nonce,
        RegistrationRequest memory rr
    ) internal returns (RegistrationResponse memory) {
        require(_validCodes[rr.referralCode] == true, "invalid refferrer code");
        address refAddress = _refCodeToRefferrer[rr.referralCode];
        addReferee(refAddress, rr.owner);
        uint256 tokenId = generateUserNftData(rr.owner);
        RegistrationResponse memory rs = RegistrationResponse(
            _nonce,
            tokenId,
            abi.encodePacked(tokenId)
        );
        return rs;
    }

    function addReferee(address to, address referree) internal {
        _referreesToReferrerAddress[to] = referree;
        uint256 index = _numReferrees[to];
        _userReferrees[to][index] = referree;
        _numReferrees[to] = index + 1;
    }

    function register(uint256 _nonce, RegistrationRequest memory rr)
        internal
   
        returns (RegistrationResponse memory)
    {
        uint256 tokenId = generateUserNftData(rr.owner);
        RegistrationResponse memory rs = RegistrationResponse(
            _nonce,
            tokenId,
            abi.encodePacked(tokenId)
        );
        return rs;
    }

    function generateUserNftData(address _to) internal returns (uint256) {
       _nftFactory.mintUserNFT(_to);
       return _nftFactory.getUserNFTId(_to);
    }

    function registerAsRefferer(string memory refCode, address userAddr)
        public
    {
        require(
            msg.sender != address(0x0) &&
                msg.sender != address(0) &&
                userAddr != address(0),
            "no zero address"
        );
        require(
            _isUser[userAddr] == true,
            "you cannot be a referral with no user"
        );
        _refCodeToRefferrer[refCode] = userAddr;
        _addrToRefCode[userAddr] = refCode;
        _validCodes[refCode] = true;
    }
}
