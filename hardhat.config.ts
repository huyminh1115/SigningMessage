import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "@openzeppelin/hardhat-upgrades";
import * as tdly from "@tenderly/hardhat-tenderly";

import "dotenv/config"

tdly.setup({ automaticVerifications: false });

const config: HardhatUserConfig = {
  defaultNetwork: "testnet",
  networks: {
    hardhat: {
      allowUnlimitedContractSize: false
    },
    // bsc: {
    //   url: BSC_URL,
    //   chainId: 56,
    //   gasPrice: 10000000000,
    //   accounts: [BSC_DEPLOY_KEY]
    // },
    // testnet: {
    //   url: BSC_TESTNET_URL,
    //   chainId: 97,
    //   gasPrice: 20000000000,
    //   accounts: [BSC_TESTNET_DEPLOY_KEY]
    // },
    // arbitrumTestnet: {
    //   url: ARBITRUM_TESTNET_URL,
    //   gasPrice: 10000000000,
    //   chainId: 421611,
    //   accounts: [ARBITRUM_TESTNET_DEPLOY_KEY]
    // },
    // arbitrum: {
    //   url: ARBITRUM_URL,
    //   gasPrice: 30000000000,
    //   chainId: 42161,
    //   accounts: [ARBITRUM_DEPLOY_KEY]
    // },
    // avax: {
    //   url: AVAX_URL,
    //   gasPrice: 200000000000,
    //   chainId: 43114,
    //   accounts: [AVAX_DEPLOY_KEY]
    // },
    // polygon: {
    //   url: POLYGON_URL,
    //   gasPrice: 100000000000,
    //   chainId: 137,
    //   accounts: [POLYGON_DEPLOY_KEY]
    // },
    // mainnet: {
    //   url: MAINNET_URL,
    //   gasPrice: 50000000000,
    //   accounts: [MAINNET_DEPLOY_KEY]
    // }
    testnet:{
      // url: "https://rpc.testnet.fantom.network",
      url: "https://fantom-testnet.public.blastapi.io",
      chainId: 4002,
      // url: "https://rpc.ankr.com/fantom_testnet",
      accounts: [process.env.key1, process.env.key2],
      gas: 3000000
    }
  },
  solidity: {
    version: "0.8.9",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },

};

export default config;
