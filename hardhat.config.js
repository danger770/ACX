require("@nomiclabs/hardhat-waffle");


const ALCHEMY_API_KEY = "l7dI0Klq2euD2SI3wM1FJ_B5C6ur9gQm";
const PRIVATE_KEY = "4ff4c1f54ffc9172aca57bd22fff489c79d0a5ed42e691f84926e9e93a916ba5";

// This is a sample Hardhat task. To learn how to create your own go to
// https://hardhat.org/guides/create-task.html
task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
  const accounts = await hre.ethers.getSigners();

  for (const account of accounts) {
    console.log(account.address);
  }
});

// You need to export an object to set up your config
// Go to https://hardhat.org/config/ to learn more

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
  solidity: "0.7.5",
  networks: {
    rinkeby: {
      url: `https://eth-rinkeby.alchemyapi.io/v2/l7dI0Klq2euD2SI3wM1FJ_B5C6ur9gQm`,
      accounts: [`${PRIVATE_KEY}`]
    }
  }
};
