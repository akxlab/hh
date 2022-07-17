// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

import "./IDna.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract DnaConsensusRounds is IDnaConsensus, Ownable, ReentrancyGuard {


    using Counters for Counters.Counter;
    Counters.Counter private _requestNonce;

    address public dnaContract;

    uint256 internal roundID;
    uint256 internal maxRounds;
    uint256 internal sampleID;

    address public leadScientist;
    address[] public peers;
    address[5] public committee;

    bytes32 public requestId;

    mapping(bytes32 => uint256) internal rndIndex;
    mapping(bytes32 => OracleConsensusResponse) internal responsesIndex;
    mapping(uint256 => bytes32) internal itemValidationIndexes;
    mapping(bytes32 => bool) internal pendingRequests;
    mapping(bytes32 => bool) internal invalidRequests;


    struct OracleConsensusResponse {
        bytes32 origReqID;
        bytes data;
        uint64 timestamp;
    }

    using ECDSA for bytes32;

    event OCCRoundStarted(bytes32 requestId, uint round, uint256 blockNum);
    event OCCRoundCompleted(uint256 time, bytes32 requestId, uint round, bytes results);
    event NewOffChainRequest(OffchainOracleRequest request);
    event Callback(bytes32 requestId, string task, bytes  params);

    constructor(address __dnaContract) {
        dnaContract = __dnaContract;
        newRequestID();
        roundID += 1;
    }



    function start() external onlyDNAContract {
        emit OCCRoundStarted(requestId, roundID, block.number);
        emit Callback(requestId, "select_lead_scientist", abi.encodePacked(peers));
    }

    function startPeerReviewing(DNASample memory sample) external onlyDNAContract override {
            emit Callback(requestId, "start_peer_reviewing", abi.encode(sample));
            newRequestID();
    }

    function selectLeadScientist() external onlyOwner override {
            leadScientist = peers[rndIndex[requestId]];
            newRequestID();

    }

    function setSelectedPeers(address[] memory peersAddresses) external onlyOwner {
        peers = peersAddresses;
    }

    function setSelectedCommittee(address[5] memory selectedCommittee) external onlyOwner {
        committee = selectedCommittee;
    }

    function getPeersPool() external onlyOwner view returns(address[] memory) {
        return peers;
    }

    function newRequestID() internal {
        string memory Prefix = "AKX_DNA_CONS_REQ";
        uint256 nonce = _requestNonce.current();
        bytes memory reqid = abi.encodePacked(Prefix, nonce);
        requestId = keccak256(reqid);
        _requestNonce.increment();
    }

    function updateRandomNumberForRequest(bytes32 reqId, uint256 rnd) external onlyOwner {
        require(rndIndex[reqId] != rnd, "akx-dna-consensus/bad-random-number");
        rndIndex[reqId] = rnd;
    }

    function setResponseData(bytes calldata data) external onlyOwner {
        OracleConsensusResponse memory r = abi.decode(data, (OracleConsensusResponse));
        responsesIndex[r.origReqID] = r;
    }

    function getValidationData(uint256 itemID) external nonReentrant returns(StampingProcess memory) {
        bytes32 index = itemValidationIndexes[itemID];
        OracleConsensusResponse memory r = responsesIndex[index];
        return abi.decode(r.data, (StampingProcess));
    }

    modifier onlyDNAContract() {
        require(msg.sender == dnaContract, "akx-dna-consensus/access-denied");
        _;
    }


}

contract DnaConsensus is IDna {

    DNAParams private _params;
    uint256 validationFee = 0.00025 ether; // about 34 cents or 0.5 AKX static fee
    address public feeHolder;
    address public roundsManager;

    DnaConsensusRounds private _rmc; // round manager contract

    constructor(address roundManager) {
        roundsManager = roundManager;
        _rmc = DnaConsensusRounds(roundsManager);
    }

    function getDNAParams() external view returns(DNAParams memory) {
        return _params;
    }
    function setDNAParams(bytes calldata params) external {
        _params = abi.decode(params, (DNAParams));
    }
    function hasDNA(address suspectedItem) external pure returns(bool) {
        return true;
    }
    function startDnaConsensus() external {
        _rmc.start();
    }



}