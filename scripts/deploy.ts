import { writeFileSync, mkdirSync } from "fs";
import path from "path";
import { artifacts, ethers, network } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log(`Deploying TaskManager with ${deployer.address} on network ${network.name}`);

  const TaskManager = await ethers.getContractFactory("TaskManager");
  const taskManager = await TaskManager.deploy();
  await taskManager.waitForDeployment();

  const contractAddress = await taskManager.getAddress();
  console.log(`TaskManager deployed at ${contractAddress}`);

  const artifact = await artifacts.readArtifact("TaskManager");

  const outputDir = path.resolve(__dirname, "../frontend");
  mkdirSync(outputDir, { recursive: true });

  const contractArtifact = {
    address: contractAddress,
    abi: artifact.abi,
    network: network.name,
    updatedAt: new Date().toISOString()
  };

  const artifactPath = path.join(outputDir, "contract.json");
  writeFileSync(artifactPath, JSON.stringify(contractArtifact, null, 2));
  console.log(`Saved artifact to ${artifactPath}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
