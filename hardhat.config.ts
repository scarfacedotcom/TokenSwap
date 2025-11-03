import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
require('dotenv').config();

const { PRIVATE_KEY, BASE_RPC_URL, BASE_SEPOLIA_RPC_URL, ETHERSCAN_API_KEY } = process.env;

console.log("PRIVATE_KEY:", PRIVATE_KEY);
console.log("BASE_RPC_URL:", BASE_RPC_URL);
console.log("BASE_SEPOLIA_RPC_URL:", BASE_SEPOLIA_RPC_URL);
console.log("ETHERSCAN_API_KEY:", ETHERSCAN_API_KEY);

if (!PRIVATE_KEY) {
  throw new Error("Please set your PRIVATE_KEY in a .env file");
}
if (!BASE_RPC_URL) {
  throw new Error("Please set your BASE_RPC_URL in a .env file");
}
if (!BASE_SEPOLIA_RPC_URL) {
  throw new Error("Please set your BASE_SEPOLIA_RPC_URL in a .env file");
}
if (!ETHERSCAN_API_KEY) {
  throw new Error("Please set your ETHERSCAN_API_KEY in a .env file");
}

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.26",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      },
      viaIR: true
    }
  },
  networks: {
    'base': {
      url: BASE_RPC_URL,
      accounts: [PRIVATE_KEY as string],
      gasPrice: 6000000,
    },
    'base-sepolia': {
      url: BASE_SEPOLIA_RPC_URL,
      accounts: [PRIVATE_KEY as string],
      gasPrice: 1000000000,
    },
  },
  etherscan: {
    apiKey: {
     "base-sepolia": ETHERSCAN_API_KEY as string,
     "base": ETHERSCAN_API_KEY as string
    },
    customChains: [
      {
        network: "base-sepolia",
        chainId: 84532,
        urls: {
         apiURL: "https://api.etherscan.io/v2/api?chainid=84532",
         browserURL: "https://sepolia.basescan.org"
        }
      },
      {
        network: "base",
        chainId: 8453,
        urls: {
         apiURL: "https://api.etherscan.io/v2/api?chainid=8453",
         browserURL: "https://basescan.org"
        }
      }
    ]
  },
  sourcify: {
    enabled: false
  },
};

export default config;
