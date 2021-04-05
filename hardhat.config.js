require("@nomiclabs/hardhat-waffle");

const INFURA_ENDPOINT = "https://rinkeby.infura.io/v3/162408c0fa52425fa3252add6d3820d7";

const RINKEBY_PRIVATE_KEY = "";


/**
 * @type import('hardhat/config').HardhatUserConfig
 */
 module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.6.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200
          }
        }
      },
    ],

  }, 

  networks: {
    rinkeby: {
      url: `${INFURA_ENDPOINT}`,
      accounts: [`0x${RINKEBY_PRIVATE_KEY}`]
    }
  }
};
