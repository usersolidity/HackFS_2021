
// import { NFTStorage, File } from 'nft.storage'
const NFTStorage = require('nft.storage')
const nftClient = new NFTStorage.NFTStorage({ token: secrets.NFTSTORAGE_API_TOKEN });
const Web3 = require('web3');
 
// If the browser has injected Web3.js
if (window.web3) {
  // Then backup the good old injected Web3, sometimes it's usefull:
  window.web3old = window.web3;
  // And replace the old injected version by the latest build of Web3.js version 1.0.0
  window.web3 = new Web3(window.web3.givenProvider);
}

var AssetInstance;
var ContractInstance;

$(document).ready(function(){
  window.ethereum.enable().then(function (accounts) {    //launches metamask to ask for connecting account
    //Contract(abi (create .js file to import),address(get from console migrate "string format"), from{account[0]})
    // The address supplied is the contract this will interact with
    AssetInstance = new window.web3.eth.contract(abiAsset, "0x9E5D45f830625F269F01b74B326d9f6c641b1946", { from: accounts[0] });
    MarketInstance = new window.web3.eth.contract(abiP2P, "0xeC563222B0b2F61177b0f65493BF4CE725F6E23b", { from: accounts[0] });
    const MarketConractAddress = 0xd44Ae8f59F640f25690E7Ff63e3F2d9429aD4cB5;

    $("#mint").on("click",mint);
    $("#approve").on("click",ApproveMarketplace);
    $("#SetOffer").on("click",SetOffer);
    $("#RemoveOffer").on("click",RemoveOffer);
    $("#GetOffers").on("click", GetOffer);
    $("#LendAsset").on("click",LendAsset);
    $("#ReturnAsset").on("click",ReturnAsset);

   function mint() {
      console.log("working")
      var metadataURI = await client.store({
        name: $("#name_input"),
        description: $("#description_input"),
        image: new NFTStorage.File(
          [
            /* data */
          ],
          $("#img_input"),
          { type: 'image/jpg' }
        ),
      })
      console.log(metadataURI.url)

      AssetInstance.methods.createAsset(metadataURI);
    };

    //Create function call ApprovalForAll Function 
    //This will allow the user to approve the P2P contract for Lending (AssetInstance)
    function ApproveMarketplace() {
      AssetInstance.methods.setApprovalForAll( MarketConractAddress, true)
    }

  
    //Create function call setOffer (MarketInstance)
    function SetOffer() {
      MarketInstance.methods.setOffer($("#Gwei"), $("#TokenIdset") );
    }


    //Create function call lendAsset (Payable) (MarketInstance)
    //Get the GWEI and make that msg.value
    function LendAsset(){
      var gweiAmount = MarketInstance.methods.getTokenGWEI($("TokenIdborrow"));
      MarketInstance.methods.LendAsset($("TokenIdborrow"), {value:web3.utils.toWei(gweiAmount,"gwei")});
    }

    //Create function call removeOffer (MarketInstance)
    function RemoveOffer(){
      MarketInstance.methods.removeOffer($("tokenIdremove"));
    }

    //Create function call returnAsset (MarketInstance)
    function ReturnAsset(){
      MarketInstance.methods.returnAsset($("tokenIdreturn"));
    }

    //Create function call returnAsset (MarketInstance)
    function GetOffer(){
      var offers = MarketInstance.methods.getAllTokenOnOffer();
      console.log(offers);
    }

    //Event that logs the creation of an Asset by Asset Contract
    AssetInstance.events.NewAssetCreation({ fromBlock: 'latest' }, function (res) {
      console.log(res);
    });
    
    //Event that logs the creation of P2PMarket Contract
    MarketInstance.events.MarketTransaction({ fromBlock: 'latest' }, function (res) {
      console.log(res);
    });
  })
});