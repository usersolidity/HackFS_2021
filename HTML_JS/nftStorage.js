import { NFTStorage, File } from 'nft.storage'
const client = new NFTStorage({ token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJkaWQ6ZXRocjoweEJFNjAzNjYxMzk2OTg5Rjk5YUU4MURGNzRGY2NFRDQ4YUFGMkYyOGEiLCJpc3MiOiJuZnQtc3RvcmFnZSIsImlhdCI6MTYyODE5MjE3ODUzMCwibmFtZSI6IkhhY2tGU18yMDIxIn0.8egYuYRc_nmWS-HyEbSYliB2ShACUq2TWEswzcnoOVI });

var web3 = new Web3(Web3.givenProvider);
var contractInstance;

$(document).ready(function() {
    window.ethereum.enable().then(function(accounts){    //launches metamask to ask for connecting account
      //Contract(abi (create .js file to import),address(get from console migrate "string format"), from{account[0]})
      // The address supplied is the contract this will interact with
      contractInstance = new web3.eth.Contract(abi, "0xB9bcF5bEa4266BB28b654661D1d2949456e5BF0E", {from: accounts[0]});
      

      $("#mint").click(mint);

      function mint() {
      var metadataURI = await client.store({
        name: $("#name_input"),
        description: $("#description_input"),
        image: new File(
          [
            /* data */
          ],
          $("#img_input"),
          { type: 'image/jpg' }
        ),
      })
      console.log(metadataURI.url)

      contractInstance.methods.createAsset(metadataURI);
 
      };

      contractInstance.events.NewAssetCreation({fromBlock: 'latest'}, function(res){
        console.log(res);
    });

});