const P2PMarketplace = artifacts.require("P2PMarketplace");
const AssetContract = artifacts.require("AssetContract");

module.exports = function(deployer){
    deployer.deploy(P2PMarketplace);
}