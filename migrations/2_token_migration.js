const Token = artifacts.require("AssetContract");

module.exports = function(deployer){
    deployer.deploy(Token);
}