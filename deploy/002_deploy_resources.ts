import {HardhatRuntimeEnvironment} from 'hardhat/types';
import {DeployFunction} from 'hardhat-deploy/types';
import {parseEther} from 'ethers/lib/utils';
import {storeAddress, readAddress} from "../helpers/config";

const func: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {


};
export default func;
func.tags = ['tokens', 'labz'];