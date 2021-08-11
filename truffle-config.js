require('babel-register');
require('babel-polyfill');

module.exports = {

  networks: {
    development: {
     host: "127.0.0.1",     
     port: 7545,            
     network_id: "*",       
     defaultEtherBalance: 500,
     accounts: 5,
    },
  },

  contracts_directory: './contracts/',
  contracts_build_directory: './build/contracts',

  mocha: {
    // timeout: 100000
  },

  compilers: {
    solc: {
       version: "0.8.0",    // Fetch exact version from solc-bin (default: truffle's version)
       optimizer: {
         enabled: true,
         runs: 200
       },
    }
  },
  db: {
    enabled: false
  }
};
