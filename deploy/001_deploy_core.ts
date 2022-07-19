import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { parseEther } from "ethers/lib/utils";
import { storeAddress, readAddress } from "../helpers/config";

const core: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployments, getNamedAccounts } = hre;
  const { deploy } = deployments;

  const { deployer, multisig } = await getNamedAccounts();

  const Repo = await deploy("ResourcesRepository", {
    from: deployer,
    args: [],
    log: true,
    waitConfirmations: 5,
  });

  try {
    await hre.run("verify:verify", { address: Repo.address });
  } catch (err) {
    console.log("cannot verify: ", err);
  }

  storeAddress("ResourcesRepository", Repo.address);
  console.log(`Resources Repository deployed to: ${Repo.address}`);

  const Bridge = await deploy("BridgeOperator", {
    from: deployer,
    args: [],
    log: true,
    waitConfirmations: 5,
  });

  try {
    await hre.run("verify:verify", { address: Bridge.address });
  } catch (err) {
    console.log("cannot verify: ", err);
  }

  storeAddress("BridgeOperator", Bridge.address);
  console.log(`Bridge Operator contract deployed to: ${Bridge.address}`);
};
export default core;
core.tags = ["core", "repo"];
