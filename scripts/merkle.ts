import * as merkletree from "merkletreejs"
import keccak256 from "keccak256";

// mock addresses to test

let mockAddresses = [
    "0xb218fFA6AcD9f17925e1897c00083a4ff0628C7B",
    "0xBeF00EB5E2bb6465E06Ccc00B6e339f646A8C92f",
    "0x00c8e289fCa00BCcFc8633b75600296622429387",
    "0x5384DA9e3DD4A3D6D1a9320B467851319D0424C1",
    "0x46C28aBA11b663F81958Ed40b88505528574b6b2",
    "0xf36E5e1A7A12330885085909960F17B1Ee0C43E5",
]

const leadNodes = mockAddresses.map(addr => keccak256(addr))
const mt = new merkletree.MerkleTree(leadNodes, {sortPairs: true})

const rootHash = mt.getRoot()

console.log(mt.getRoot())