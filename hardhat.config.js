require("@nomiclabs/hardhat-waffle");
const fs = require("fs")
const privateKey = fs.readFileSync(".secret").toString()

module.exports = {
  network: {
    hardhat: {
      chainId: 1337
    },
    mumbai: {
      url: 'https://polygon-testnet.blastapi.io/1cfeba91-6192-4ded-9119-2c02e172cf47',
      accounts:[privateKey]
    },
    mainnet:{
      url: 'https://polygon-mainnet.blastapi.io/1cfeba91-6192-4ded-9119-2c02e172cf47',
      accounts:[privateKey]
    }
  },
  solidity: "0.8.4",
};
