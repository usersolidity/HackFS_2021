// import { NFTStorage, File } from 'nft.storage'
const NFTStorage = require('nft.storage')
const NFTSTORAGE_API_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweEJFNjAzNjYxMzk2OTg5Rjk5YUU4MURGNzRGY2NFRDQ4YUFGMkYyOGEiLCJpc3MiOiJuZnQtc3RvcmFnZSIsImlhdCI6MTYyODE5MjE3ODUzMCwibmFtZSI6IkhhY2tGU18yMDIxIn0.8egYuYRc_nmWS-HyEbSYliB2ShACUq2TWEswzcnoOVI'
const nftClient = new NFTStorage.NFTStorage({ token: NFTSTORAGE_API_TOKEN });
const Web3 = require('web3');

var web3 = new Web3(Web3.givenProvider);
var AssetInstance;
var ContractInstance;

$(document).ready(function () {
  window.ethereum.enable().then(function (accounts) {    //launches metamask to ask for connecting account
    //Contract(abi (create .js file to import),address(get from console migrate "string format"), from{account[0]})
    // The address supplied is the contract this will interact with
    AssetInstance = new web3.eth.Contract(abi, "0x55ad78988D3A09e0960c40A467474FF9D4C91B2a", { from: accounts[0] });
    MarketInstance = new web3.eth.Contract(abi2, "0xd44Ae8f59F640f25690E7Ff63e3F2d9429aD4cB5", { from: accounts[0] });
    const MarketConractAddress = 0xd44Ae8f59F640f25690E7Ff63e3F2d9429aD4cB5;

    $("#mint").click(mint);
    //ApproveMarketplace
    //SetOffer (GWEI Per Period, TokenId)
    //RemoveOffer (TokenId)
    //LendAsset (tokenId, GWEI to Cover Cost)
    //ReturnAsset (TokenId)

    async function mint() {
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
      MarketInstance.methods.setOffer($("Gwei"), $("tokenId") );
    }


    //Create function call lendAsset (Payable) (MarketInstance)
    //Get the GWEI per period and make that msg.value


    //Create function call removeOffer (MarketInstance)
    function RemoveOffer(){
      MarketInstance.methods.removeOffer($("tokenId"));
    }

    //Create function call returnAsset (MarketInstance)
    function ReturnAsset(){
      MarketInstance.methods.returnAsset($("tokenId"));
    }

    //Event that logs the creation of an Asset by Asset Contract
    AssetInstance.events.NewAssetCreation({ fromBlock: 'latest' }, function (res) {
      console.log(res);
    });
  })
});