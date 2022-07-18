import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {parseEther} from 'ethers/lib/utils';
import {storeAddress, readAddress} from "../helpers/config";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const {deployments, getNamedAccounts} = hre;
  const {deploy} = deployments;

  const {deployer, multisig} = await getNamedAccounts();

  const Labz = await deploy('Labz', {
    from: deployer,
    args: [multisig],
    log: true,
    waitConfirmations: 5,
  });

  try {
  await hre.run("verify:verify", {address: Labz.address, constructorArgs:[multisig]});
  } catch(err) {
    console.log("cannot verify: ", err);
  }

  storeAddress("Labz", Labz.address);
  console.log(`Labz ERC20 token deployed to: ${Labz.address}`);


};
export default func;
func.tags = ['tokens', 'labz'];