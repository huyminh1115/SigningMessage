import { ethers } from "hardhat";

async function main() {
  const scoreContract = await ethers.getContractAt("ScoreContract", process.env.ScoreContract);
  const leaderReward = await ethers.getContractAt("LeaderReward", process.env.LeaderReward);

  // Add score:
  // await (await scoreContract.mint(process.env.GOV, 2900)).wait();

  // Check score:
  let score = await scoreContract.balanceOf(process.env.GOV);
  score = 5000000;
  console.log("Score: ", score);

  // sign contract
  const accounts = await ethers.getSigners();
  console.log("process.env.GOV: ", process.env.GOV);
  console.log("account: ", accounts[0].address);

  // user, balance
  let values = [process.env.GOV, score];
  let types = ['address', 'uint256'];

  let encodedMessage = ethers.utils.solidityPack(types, values);
  console.log("encodedMessage: ", encodedMessage);

  let hashEncodedMessage = ethers.utils.keccak256(encodedMessage);

  console.log("hashEncodedMessage", hashEncodedMessage);

  const signature = await accounts[0].signMessage(ethers.utils.arrayify(hashEncodedMessage));
  console.log("signature: ", signature);

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
