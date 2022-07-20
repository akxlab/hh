import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { parseEther, solidityKeccak256 } from "ethers/lib/utils";
import { storeAddress, readAddress } from "../helpers/config";
import { ethers } from "hardhat";

const core: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const signers = await ethers.getSigners()
  const deployer = signers[0].address;

  const Repo = await deploy("ResourcesRepository", {
    from: deployer,
    args: [],
    log: true,
   waitConfirmations: 2,
  });


  storeAddress("ResourcesRepository", Repo.address);
  console.log(`Resources Repository deployed to: ${Repo.address}`);

  const Labz = await deploy("Labz", {
    from: deployer,
    log:true,
    waitConfirmations:2,
  });

  const PrivateSale = await deploy("AKXPrivateSale", {
    from: deployer,
    args: [Labz.address, deployer, ethers.utils.parseEther('0.000001') ],
    log:true,   waitConfirmations: 2,
  });

  

  storeAddress("PrivateSale", PrivateSale.address);
  console.log(`private sale deployed to: ${PrivateSale.address}`);

 const token = await ethers.getContractAt("Labz", Labz.address, signers[0]);



 const tx = await token.grantPresaleRole(PrivateSale.address);
 await tx.wait()
 console.log(tx.hash);




 /* const Bridge = await deploy("BridgeOperator", {
    from: deployer,
    args: [],
    log: true,
  //  waitConfirmations: 5,
  });*/

 /* try {
    await hre.run("verify:verify", { address: Bridge.address });
  } catch (err) {
    console.log("cannot verify: ", err);
  }*/

 /* storeAddress("BridgeOperator", Bridge.address);
  console.log(`Bridge Operator contract deployed to: ${Bridge.address}`);*/
};
export default core;
core.tags = ["core", "repo"];
