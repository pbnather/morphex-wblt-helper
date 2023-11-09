import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from 'dotenv';
dotenv.config();

const config: HardhatUserConfig = {
  solidity: "0.7.5",
  networks: {
    base: {
      url: 'https://base.llamarpc.com',
      chainId: 8453,
      accounts: [process.env.PRIVATE_KEY as string]
    },
  },
  etherscan: {
    apiKey: {
      base: process.env.BASESCAN_KEY as string
    }
  }
};

export default config;
