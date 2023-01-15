import { ethers } from "hardhat";

async function main() {
  const Verifier = await ethers.getContractFactory("Verifier");
  const verifier = await Verifier.deploy(process.env.GOV);

  await verifier.deployed();

  console.log(`Contract deployed to ${verifier.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
