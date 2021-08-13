//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Ownable.sol";

/*
 * Market place to trade kitties (should **in theory** be used for any ERC721 token)
 * It needs an existing P2P contract to interact with
 * Note: it does not inherit from the P2P contracts
 * Note: The contract needs to be an operator for everyone who is selling through this contract.
 */
interface IP2PMarketplace {

    event MarketTransaction(string TxType, address owner, uint256 tokenId);

    /**
    * Set the current P2PContract address and initialize the instance of P2Pcontract.
    * Requirement: Only the contract owner can call.
     */
    function setAssetContract(address _AssetContractAddress) external;

    /**
    * Get the details about a offer for _tokenId. Throws an error if there is no active offer for _tokenId.
     */
    function getOffer(uint256 _tokenId) external view returns ( 
        address lender, 
        uint256 dollarsPerPeriod, 
        uint256 tokenId, 
        bool activeOffering,
        bool activelyBorrowed);

    /**
    * Get all tokenId's that are currently for sale. Returns an empty arror if none exist.
     */
    function getAllTokenOnOffer() external view  returns(uint256[] memory listOfOffers);

    /**
    * Creates a new offer for _tokenId for the price _price.
    * Emits the MarketTransaction event with txType "Create offer"
    * Requirement: Only the owner of _tokenId can create an offer.
    * Requirement: There can only be one active offer for a token at a time.
    * Requirement: Marketplace contract (this) needs to be an approved operator when the offer is created.
     */
    function setOffer(uint256 _dollarsPerPeriod, uint256 _tokenId) external;

    /**
    * Removes an existing offer.
    * Emits the MarketTransaction event with txType "Remove offer"
    * Requirement: Only the seller of _tokenId can remove an offer.
     */
    function removeOffer(uint256 _tokenId) external;

    /**
    * Executes the purchase of _tokenId.
    * Sends the funds to the seller and transfers the token using transferFrom in P2Pcontract.
    * Emits the MarketTransaction event with txType "Buy".
    * Requirement: The msg.value needs to equal the price of _tokenId
    * Requirement: There must be an active offer for _tokenId
     */
    function lendAsset(uint256 _tokenId) external payable;

    function returnAsset(uint256 _tokenId) external;

    function Withdraw(uint256 amountToTransfer) external;

    function getTokenGWEI(uint256 tokenId) external returns(uint256 price);
}
