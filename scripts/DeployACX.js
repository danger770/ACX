// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');

  // We get the contract to deploy

  const ACXaddress = "0xCfbeD470aEEf35f931D309585Ce7902dE033A55e";
  const DAIaddress = "0xc7AD46e0b8a400Bb3C915120d284AafbA8fc4735";
  const presaleInitialPrice = BigInt(90000000000000000000);
  const presalePriceFactor = 10000015;
  const vestingTime = 5;
  const vestingPercentage = 1000;
  console.log("initializing deployments!");
  const PreSale = await hre.ethers.getContractFactory("PreSale");
  const presale = await PreSale.deploy(ACXaddress, DAIaddress, presaleInitialPrice, presalePriceFactor);
  console.log("presale deployed!");
  const instPreSale = await presale.deployed();
  console.log("Presale address : ",instPreSale.address);
  const Vesting = await hre.ethers.getContractFactory("VestingPresale");
  const vesting = await Vesting.deploy(instPreSale.address, ACXaddress, vestingTime, vestingPercentage);
  console.log("vesting deployed!");
  const instVesting = await vesting.deployed();
  console.log("vesting address : ", instVesting.address);

  await instPreSale.initialize(instVesting.address);
  console.log("presale initialized");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
