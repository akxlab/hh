import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { parseEther, solidityKeccak256 } from "ethers/lib/utils";
import { storeAddress, readAddress } from "../helpers/config";
import { ethers } from "hardhat";

const r: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const signers = await ethers.getSigners()
  const deployer = signers[0].address;

  const UNFT = await deploy("UserNFT", {
    from: deployer,
    args: [],
    log: true,
   waitConfirmations: 2,
  });
  storeAddress("UserNFT", UNFT.address);
  console.log(`USER NFT deployed to: ${UNFT.address}`);

  const factory = await deploy("UserFactory", {
    from: deployer,
    args: [UNFT.address],
    log: true,
   waitConfirmations: 2,
  });
  storeAddress("UserFactory", factory.address);
  console.log(`USER Factory deployed to: ${factory.address}`);
  const token = await ethers.getContractAt("UserNFT", UNFT.address, signers[0]);



  const tx = await token.grantMinterRole(factory.address);
  await tx.wait()
  console.log(tx.hash);

  

};
export default r;
r.tags = ['resource', 'labz'];