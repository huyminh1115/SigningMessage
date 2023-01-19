import { ethers, upgrades} from "hardhat";

async function main() {
  const LeaderReward = await ethers.getContractFactory("LeaderReward");
  const leaderReward = await upgrades.deployProxy(LeaderReward, [process.env.GOV, process.env.GOV, process.env.BTC]);
  await leaderReward.deployed();
  console.log(`Contract deployed to ${leaderReward.address}`);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
