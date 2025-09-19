import { HardhatUserConfig, subtask } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import * as dotenv from "dotenv";
import { TASK_COMPILE_SOLIDITY_GET_SOLC_BUILD } from "hardhat/builtin-tasks/task-names";

dotenv.config();

const { SEPOLIA_RPC_URL, PRIVATE_KEY } = process.env;

subtask(TASK_COMPILE_SOLIDITY_GET_SOLC_BUILD, async (args: any, _hre, runSuper) => {
  if (args.solcVersion === "0.8.24") {
    const compilerPath = require.resolve("solc/soljson.js");
    return {
      compilerPath,
      isSolcJs: true,
      version: args.solcVersion,
      longVersion: args.solcVersion
    };
  }

  return runSuper(args);
});

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.24",
    settings: {
      optimizer: { enabled: true, runs: 200 }
    }
  },
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    localhost: {
      url: "http://127.0.0.1:8545"
    },
    sepolia: {
      url: SEPOLIA_RPC_URL || "",
      accounts: PRIVATE_KEY ? [PRIVATE_KEY] : []
    }
  },
  mocha: {
    timeout: 60000
  }
};

export default config;
