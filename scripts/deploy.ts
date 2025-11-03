import { ethers } from 'hardhat';

async function main() {
  const ContractFactory = await ethers.getContractFactory("TokenSwap");
  const deployTx = await ContractFactory.getDeployTransaction();
  const gasEstimate = await ethers.provider.estimateGas(deployTx);
  console.log("Estimated gas:", gasEstimate.toString());

  const tokenSwap = await ethers.deployContract("TokenSwap", [], {
  gasLimit: Number(gasEstimate.toString()) * 2 // double the estimate just to be safe
});

  await tokenSwap.waitForDeployment();

  console.log('TokenSwap Contract Deployed at ' + tokenSwap.target);

}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});