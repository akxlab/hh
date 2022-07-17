// SPDX-License-Identifier: MIT
pragma solidity ^0.8.14;

interface IDna {
        struct DNAParams {
                uint256 fitness;
                uint256 maxPop;
                uint256 growthRate;
                uint256 mutationRate;
                uint256 commonAncestorA;
                uint256 commonAncestorB;
        }



        function getDNAParams() external returns(DNAParams memory);
        function setDNAParams(bytes calldata params) external;
        function hasDNA(address suspectedItem) external returns(bool);
        function startDnaConsensus() external;


}

interface IDnaConsensus {

        event NewSampleRequest(address indexed owner, uint256 itemID);
        event LeadScientistSelected(address indexed _leadScientist);
        event PeersConfirmed(address[] peers);
        event PeerReviewConsensusStarted(uint256 time, uint256 itemID, uint256 consensusID);
        event PeerReviewConfirmed(uint256 time, uint256 itemID, string proofHex);


        struct PeerReviewing {
            uint256 minNumberOfScientists;
            uint256 minLevelForLead;
            address leadScientist;
            address[] peerScientists;
            uint256 sampleToAnalyze;
            uint256 deadline;
            bool stamped;
        }

        struct StampingProcess {
                // need a minimum of 5 address to make a stamping committee
           address[5] stampingCommittee;
           bytes32 stampRecordID;
           uint256 timestamp;
           bytes[] stampSignatures;
           string merkleProofHex;
        }

        struct DNASample  {
           address owner;
           uint256 itemID;
           bytes32 unsignedDNA;
           bytes r;
           bytes s;
           bytes v;
        }

        struct OffchainOracleRequest {
           bytes32 requestId;
           address from;
           uint256 forItemID;
           uint8 roundID;
           uint256 estimatedFees;
           address[] peers;
           bytes[] extraData;
        }

        function selectLeadScientist() external;
        function startPeerReviewing(DNASample memory sample) external;



}

