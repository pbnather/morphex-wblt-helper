import { run, ethers, network } from "hardhat";
// import { mockAddresses, oldTokenAddresses } from "../constants/addresses";
// const lzEndpoints = require("../constants/layerzeroEndpoints.json");

const WETH = "0x4200000000000000000000000000000000000006";
const WBLT = "0x4E74D4Db6c0726ccded4656d0BCE448876BB4C7A";
const REWARD_ROUTER = "0x49A97680938B4F1f73816d1B70C3Ab801FAd124B";
const GLP_MANAGER = "0x9fAc7b75f367d5B35a6D6D0a09572eFcC3D406C5";
const STAKED_GLP = "0x64755939a80BC89E1D2d0f93A312908D348bC8dE";

async function main() {
  console.log(`Deploying BaseAdapter02 on ${network.name}`);

  let baseADapter02Factory = await ethers.getContractFactory("BaseAdapter02");

  let baseAdapter02 = await baseADapter02Factory.deploy(WETH, WBLT, REWARD_ROUTER, GLP_MANAGER, STAKED_GLP);
  await baseAdapter02.waitForDeployment();
  let baseAdapter02Address = await baseAdapter02.getAddress();
  console.log(`BaseAdapter02 deployed at ${baseAdapter02Address}`);

  let waitingTime = await new Promise(resolve => setTimeout(resolve, 10000));
  console.log(waitingTime);

  await run("verify:verify", {
    address: await baseAdapter02.getAddress(),
    constructorArguments: [
      WETH, WBLT, REWARD_ROUTER, GLP_MANAGER, STAKED_GLP
    ],
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
