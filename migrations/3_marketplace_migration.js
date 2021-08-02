const Token = artifacts.require("P2PMarketplace");
const AssetContract = artifacts.require("AssetContract");


module.exports = function(deployer){
    deployer.deploy(Token);
}