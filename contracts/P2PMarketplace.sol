//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./AssetContract.sol";
import "./IP2PMarketplace.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract P2PMarketplace is Ownable, IP2PMarketplace{
    //Allows for function calls from the Asset Contract
    AssetContract private _AssetContract;

    //Mapping that stores the NFT information for an Asset
    struct Offer {
        address payable lender;
        uint256 durationOfLend;
        uint256 dollarsPerPeriod;
        uint256 tokenId;
        bool activeOffering;
        bool activelyBorrowed;
    }

    Offer[] offers;

    mapping(uint256 => Offer) tokenIdToOffer;

    //Mapping that stores a borrowed asset instance
    struct borrowedAsset{
        address payable Borrower;
        uint256 PricePaid;
        bool Active;
    }

    borrowedAsset[] BorrowedAssets;

    mapping(uint256 => borrowedAsset) tokensBorrowed;

    /**
    * Set the current AssetContract address and initialize the instance of AssetContract.
    * Requirement: Only the contract owner can call.
     */
    constructor() public{
        owner = msg.sender;
    }
    
    function setAssetContract(address _AssetContractAddress) external override onlyOwner{
        _AssetContract = AssetContract(_AssetContractAddress);
    }

    /**
    * Get the details about a offer for _tokenId. Throws an error if there is no activeOffering offer for _tokenId.
     */
    function getOffer(uint256 _tokenId) external view override  returns ( 
        address lender, 
        uint256 dollarsPerPeriod, 
        uint256 durationOfLend, 
        uint256 tokenId, 
        bool activeOffering,
        bool activelyBorrowed){
        require(tokenIdToOffer[_tokenId].activeOffering, "No active offering for that Asset");
            return (
                tokenIdToOffer[_tokenId].lender,
                tokenIdToOffer[_tokenId].dollarsPerPeriod,
                tokenIdToOffer[_tokenId].durationOfLend,
                tokenIdToOffer[_tokenId].tokenId,
                tokenIdToOffer[_tokenId].activeOffering,
                tokenIdToOffer[_tokenId].activelyBorrowed);
        }

    /**
    * Get all tokenId's that are currently available for lend. 
    * Returns an empty array if none exist.
     */
    function getAllTokenOnOffer() external view override returns(uint256[] memory listOfOffers) {
        uint256 _length = offers.length;

        uint256[] memory _offers;

        for(uint i=0; i<_length; i++){
            if(offers[i].activeOffering && offers[i].activelyBorrowed == false){
                if(_offers.length == 0){
                    _offers[0] = offers[i].tokenId;
                }
                _offers[(_offers.length-1)] = offers[i].tokenId;
            }
        }
        return _offers;
    }

    /*
    * Creates a new offer for _tokenId for the dollarsPerPeriod _dollarsPerPeriod.
    * Transfers control of Asset to the Smart Contract
    * Emits the MarketTransaction event with txType "Asset Available for Lending"
    * If offer had been created in the past sets it back to active and updates duration and dollars
    * Requirement: Only the owner of _tokenId can create an offer.
    * Requirement: There can only be one activeOffering offer for a token at a time.
    * Requirement: Transfer token before creating offer to prevent active offer without token transfer
     */
    function setOffer(uint256 _durationOfLend, uint256 _dollarsPerPeriod, uint256 _tokenId) external override {
        require(_AssetContract.ownerOf(_tokenId) == msg.sender, "Only the onwner can list a Asset for Sale");
        require(tokenIdToOffer[_tokenId].activeOffering != true, "Asset already has an activeOffering offer");
       
        tokenIdToOffer[_tokenId].lender = payable(msg.sender);
        tokenIdToOffer[_tokenId].durationOfLend = _durationOfLend;
        tokenIdToOffer[_tokenId].dollarsPerPeriod = _dollarsPerPeriod;
        tokenIdToOffer[_tokenId].tokenId = _tokenId;
        tokenIdToOffer[_tokenId].activeOffering = false;
        tokenIdToOffer[_tokenId].activelyBorrowed = false;

        offers.push(tokenIdToOffer[_tokenId]);
        
        _AssetContract.safeTransferFrom(msg.sender, address(_AssetContract), _tokenId);
        
        tokenIdToOffer[_tokenId].activeOffering = true;
        tokenIdToOffer[_tokenId].durationOfLend = _durationOfLend;
        tokenIdToOffer[_tokenId].dollarsPerPeriod = _dollarsPerPeriod;
       
       emit MarketTransaction("Asset Available for Lending", msg.sender, _tokenId);
    } 


    /**
    * Removes an existing offer by returning the asset to the Owner
    * Emits the MarketTransaction event with txType "Asset Removed From Lending"
    * Requirement: Only the lender of _tokenId can remove an offer.
     */
    function removeOffer(uint256 _tokenId) external override {
        //require(tokenIdToOffer[_tokenId].lender == msg.sender, "Only the Owner can Remove an Asset");
        require(tokenIdToOffer[_tokenId].activelyBorrowed == false, "Asset is currently borrowed");
        
        
        _AssetContract.safeTransferFrom(address(_AssetContract), tokenIdToOffer[_tokenId].lender, _tokenId);
        offers[_tokenId].activeOffering = false;
        
        emit MarketTransaction("Asset Removed From Lending", tokenIdToOffer[_tokenId].lender, _tokenId);
    }


    /**
    * Executes the lending of _tokenId.
    * Sends the price to the contract.
    * Emits the MarketTransaction event with txType "Lent".
    * FEE MUST BE BUILT INTO THE FRONT END CODE
    * Requirement: The msg.value must be greater then dollarsPerPeriod of _tokenId to account for price and fees
    * Requirement: There must be an activeOffering offer for _tokenId
     */
    function lendAsset(uint256 _tokenId) external payable override {
        require(tokenIdToOffer[_tokenId].activeOffering == true, "Asset is not available");
        require(msg.value > (tokenIdToOffer[_tokenId].dollarsPerPeriod), "Message value too low");
        require(tokenIdToOffer[_tokenId].activelyBorrowed == false, "Asset is currently Borrowed");

        uint256 borrowId = BorrowedAssets.length;

        tokensBorrowed[borrowId].Borrower = payable(msg.sender);

        tokensBorrowed[borrowId].PricePaid = msg.value;
        tokensBorrowed[borrowId].Active = true;

        BorrowedAssets.push(tokensBorrowed[borrowId]);

        tokenIdToOffer[_tokenId].activelyBorrowed = true;

        emit MarketTransaction("Asset Lent", msg.sender, _tokenId);
    }

    /**
    * Returns an token to owner
    * No funds sent as payment was already sent
    * Require original lender to call this function as they own token
     */
    function returnAsset(uint256 _tokenId) external override {
        //require(tokensBorrowed[_tokenId].Borrower == msg.sender, "Only the Borrower can return an offer");
        require(tokenIdToOffer[_tokenId].activelyBorrowed == true, "Asset is not currently Borrowed");

        tokenIdToOffer[_tokenId].activelyBorrowed = false;
        tokensBorrowed[_tokenId].Active = false;
        
        uint256 lenderProfit = SafeMath.mul( (tokenIdToOffer[_tokenId].dollarsPerPeriod), SafeMath.div(99,100) );
        uint256 borrowerCollateral = 
                (tokensBorrowed[_tokenId].PricePaid - tokenIdToOffer[_tokenId].dollarsPerPeriod) -
                (SafeMath.mul( (tokenIdToOffer[_tokenId].dollarsPerPeriod) ,  SafeMath.div(99,100) ) );

        tokenIdToOffer[_tokenId].lender.transfer(lenderProfit);
        tokensBorrowed[_tokenId].Borrower.transfer(borrowerCollateral);
        

        emit MarketTransaction("Asset Returned", tokenIdToOffer[_tokenId].lender, _tokenId);
    }

    function Withdraw(uint256 amountToTransfer) external onlyOwner override {
        payable(msg.sender).transfer(amountToTransfer);
    }
    
    function contractBalance() external view returns (uint256){
        return address(this).balance;
    }
}