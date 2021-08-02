pragma solidity ^0.5.12;
import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./ERC721Holder.sol";
import "./Ownable.sol";

contract AssetContract is IERC721, Ownable, ERC721Holder{
    
    //Names of dApp and token symbol
    string public constant dAppName = "P2PMarketplace";
    string public constant globalTokenSymbol = "P2PMKT";

    //Values used to complete ERC721 compatability check before safeTransfer functions
    bytes4 internal constant IERC721ReturnValue = bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"));
    bytes4 private constant _INTERFACE_ID_ERC721 = 0x80ac58cd;
    bytes4 private constant _INTERFACE_ID_ERC165 = 0x01ffc9a7;

    function supportsInterface(bytes4 _interfaceId) external pure returns(bool){
        return (_interfaceId == _INTERFACE_ID_ERC165 || _interfaceId == _INTERFACE_ID_ERC721);
    }

    constructor() public{
        owner = msg.sender;
    }
    
    //Structure that stores token information for each Asset
    struct Asset {
        uint256 assetId;
        uint256 assetValue;
        bool currentlyBorrowed;  
    }
    
    Asset[] itemsForOffer;

    //Mapping that links owner to Asset and Assets
    mapping (uint256 => address) public AssetIndextoOwner;
    mapping (address => uint256) AssetOwnershipCount;

    /** 
    * Mapping to be ERC721 Compliant
    */
    mapping (uint256 => address) public AssetIndexToApproved;
    //Double Mapping for Approve All Tokens Functions (MyAddress => OperatorAddress => True/False) 
    mapping (address => mapping (address => bool)) public  _operatorApprovals;

    
    event NewAssetCreation(address owner, uint256 newAssetId, uint256 assetValue, bool currentlyBorrowed);

    function balanceOf(address owner) external view returns (uint256){
        return AssetOwnershipCount[owner];
    }

    /*
     * @dev Creates new Asset Token.
     *
     * assetValue is the value of real world Asset
     */ 
    function createAsset(uint256 assetValue) public returns (uint256){

        //Create new Asset, send it to msg.sender
        return _createAsset(assetValue, false, msg.sender);
    }

    /*
     * @dev Returns the total number of tokens in circulation.
     */
    function totalSupply() external view returns (uint256){
        return itemsForOffer.length;
    }

    /*
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory){
        return dAppName;
    }

    /*
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory){
        return globalTokenSymbol;
    }

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 _tokenId) external view returns (address){
        return AssetIndextoOwner[_tokenId];
    }
    
    //Get Asset Info Function
    //Input Asset and get out all cat details
    function getAssetInfo(uint256 _index) external view 
    returns (
        uint256 assetId, 
        uint256 assetValue, 
        bool currentlyBorrowed)
            {
                Asset storage AssetInfo = itemsForOffer[_index];

                assetId = AssetInfo.assetId;
                assetValue = uint256(AssetInfo.assetValue);
                currentlyBorrowed = bool(AssetInfo.currentlyBorrowed);
            }

     /* @dev Transfers `tokenId` token from `msg.sender` to `to`.
     * Requirements:
     * - `to` cannot be the zero address.
     * - `to` can not be the contract address.
     * - `tokenId` token must be owned by `msg.sender`.
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 tokenId) external{
        require(to != address(0x0),'Address Cannot be NULL');
        require(AssetIndextoOwner[tokenId] == msg.sender, 'Sender Must be Owner');
    
        
        _transfer(msg.sender, to, tokenId);
    }

    // Internal function which will be used by transfer to swap token ownership
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        AssetOwnershipCount[_to] ++;
        if (_to == address(this)){
            AssetIndexToApproved[_tokenId];
        }
        
        AssetOwnershipCount[_from] --;
        AssetIndextoOwner[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }


// CREATE NEW Asset FUNCTION 
    function _createAsset(uint256 _assetValue, bool _currentlyBorrowed, address _owner) internal returns(uint256){
        
        Asset memory _Asset = Asset({
            assetId: itemsForOffer.length,
            assetValue: uint256(_assetValue),
            currentlyBorrowed: bool(_currentlyBorrowed)
        });

        itemsForOffer.push(_Asset);

        uint256 newAssetId = (itemsForOffer.length)-1;

        _transfer(address(0x0), _owner, newAssetId);

        emit NewAssetCreation(_owner, newAssetId, _assetValue, _currentlyBorrowed);

        return newAssetId;
    }

    /** 
    * Safetransfer functions that check the address can recieve ERC721 tokens before sending
    * Uses function _checkERC721Support to check for receivability
    * Ensures the address can handle token but not that it is correct address
    */
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes memory data) public{
        require( _checkTransferParameters(_from, _to, _tokenId) , "Message.Sender must be Token Owner, or Approved by Owner");
        _safeTransfer(_from, _to, _tokenId, data);
    
    }

    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external{
        safeTransferFrom(_from, _to, _tokenId, "");
    }


    function transferFrom(address _from, address _to, uint256 _tokenId) external{
        require( _checkTransferParameters(_from, _to, _tokenId) , "Message.Sender must be Token Owner, or Approved by Owner");
        _transfer(_from, _to, _tokenId);
    }

    function _safeTransfer(address _from, address _to, uint256 _tokenId, bytes memory _data) internal {
        require(_checkERC721Support(_from, _to, _tokenId, _data), "To Address Must be Capable of Receiving Token");
        _transfer(_from, _to, _tokenId);
    }

    /**
    * Function to check that address is able to receive ERC721 token address
    * Utilizes IERC721Receiver.sol to complete check vs IERC721ReturnValue
     */
    function _checkERC721Support(address _from, address _to, uint256 _tokenId, bytes memory _data) internal returns(bool){
        if( !_isContract(_to) ){
            return true;
        }
        
        //Call onERC721Received at _to address
        bytes4 returnData = IERC721Receiver(_to).onERC721Received(msg.sender, _from, _tokenId, _data);
        
        //Check that return value is equal to ERC721 token standards
        return returnData == IERC721ReturnValue;
    }

    function _isContract(address _to) view internal returns(bool){
            uint256 size;
            assembly{
                size := extcodesize(_to)
            }
            return size > 0;
    }

    /*
     * @dev Checks Owner of Token, Address is not (0x0), and tokenId is valid.
     * Returns true if they all are valid.
     * Used in transfer functions to ensure that parameters are met.
     */
    function _checkTransferParameters(address _from, address _to, uint256 _tokenId) internal view returns(bool){
        if(_from != address(this)){
        require(_to != address (0x0), "Cannot Send to a Zero Address");
        require((_tokenId < itemsForOffer.length), 'Must be a valid Asset');
        require(_from == msg.sender || 
                AssetIndexToApproved[_tokenId] == msg.sender || 
                _operatorApprovals[AssetIndextoOwner[_tokenId]][msg.sender],
                "Message.Sender must be Token Owner, or Approved by Owner");
        }

        return true;
    }

    /*
     * @dev Checks the owner of a given token.
     * Returns true if they are the owner.
     * Used in transfer functions to ensure that msg.sender is owner of token 
     */
    function _checkOwnership(address _toCheck, uint256 _tokenId) internal view returns(bool){
        if(_toCheck != address(this)){
        require(_toCheck == AssetIndextoOwner[_tokenId], "Message.Sender must be Token Owner");
        }
        return true;
    }

    /**
    *
    * Required Mapping to be ERC721 compliant
    * Not used in this contract as design is structured different
    *
     */
    function approve(address _approved, uint256 _tokenId) external{
        require(
            AssetIndextoOwner[_tokenId] == msg.sender || 
            AssetIndexToApproved[_tokenId] == msg.sender || 
            _operatorApprovals[AssetIndextoOwner[_tokenId]][msg.sender] == true, "Message.Sender must be Token Owner");
        
        _approve(_approved, _tokenId);
    }

    function _approve(address _approved, uint256 _tokenId) internal{
        
        AssetIndexToApproved[_tokenId] = _approved;
        
        emit Approval(AssetIndextoOwner[_tokenId], _approved, _tokenId);
    }

    function setApprovalForAll(address _operator, bool _approved) external{
        require(_approved = true || false, "Must Enter True or False");
        require(_operator != msg.sender, "Cannot approve yourself");
        require(_operator != address (0x0), "Cannot Approve a Zero Address");
        
        _approvalForAll(_operator, _approved);
    }

    function _approvalForAll(address _operator, bool _approved) internal {
        _operatorApprovals[msg.sender][_operator] = _approved;

        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    function getApproved(uint256 _tokenId) external view returns (address){
        require((_tokenId < itemsForOffer.length), 'Must be a valid Asset');

        return (AssetIndexToApproved[_tokenId]);
    }

    function isApprovedForAll(address _owner, address _operator) external view returns (bool){
        return _operatorApprovals[_owner][_operator];
    }
}    