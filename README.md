# HackFS_2021
A P2P marketplace that uses ERC-721 Token standards 

Steps to Use
Create a token for Lending
1) Deploy AssetContract.sol and P2PMarketplace.sol
2) Call function setAssetContract in P2PMarketplace.sol sending in address of deployed AssetContract.sol
3) Mint NFT.storage
4) Call AssetContract function createAsset sending in url of nft as variable. Will return a tokenId number
5) Call AssetContract function setApprovalForAll sending in deployed address of P2PMarketplace and true as variables
6) Call P2PMarketplace function setOffer sending in price desired in Gwei and tokenId as variables
7) Optional Step call P2PMarketPlace function removeOffer sending in tokenId as variable

Become a Borrower
1) Call P2PMarketplace function getAllTokenOnOffer to retreive all assets available
2) Look through returned offers for desired asset
3) Call P2PMarketplace function lendAsset sending in tokenId as variable and amount in Gwei as msg.value
4) When returning asset Call P2PMarketplace function returnAsset sending in tokenId as variable


