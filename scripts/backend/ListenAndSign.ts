import { ethers } from "hardhat";

async function main() {
  const scoreContract = await ethers.getContractAt("ScoreContract", process.env.ScoreContract);
  const verifier = await ethers.getContractAt("Verifier", process.env.Verifier);

  // Add score:
  // await (await scoreContract.mint(process.env.GOV, 100)).wait();

  // Check score:
  let score = await scoreContract.balanceOf(process.env.GOV);
  console.log("Score: ", score);

  let nounce = 1;

  // sign contract
  const accounts = await ethers.getSigners();
  console.log("process.env.GOV: ", process.env.GOV);
  console.log("account: ", accounts[0].address);

  // user, balance, nounce
  let values = [process.env.GOV, score, nounce];
  let types = ['address', 'uint256', 'uint256'];

  let encodedMessage = ethers.utils.solidityPack(types, values);
  console.log("encodedMessage: ", encodedMessage);

  let hashEncodedMessage = ethers.utils.keccak256(encodedMessage);

  console.log("hashEncodedMessage", hashEncodedMessage);

  const signature = await accounts[0].signMessage(ethers.utils.arrayify(hashEncodedMessage));
  console.log("signature: ", signature);


  let verifySuccess = await verifier.verifySignature(process.env.GOV, score, nounce, signature);
  console.log("verify state: ", verifySuccess);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
