pragma solidity ^0.4.18;

import "./internals/ERC721.sol";
import "./internals/Ownable.sol";
import "./internals/Pausable.sol";
import "installed_contracts/oraclize-api/contracts/usingOraclize.sol";

contract TweetChain is ERC721, Ownable, Pausable, usingOraclize {
  /*** CONSTANTS ***/

  address public owner;
  string public constant name = "TweetChain";
  string public constant symbol = "TWEET";

  bytes4 constant InterfaceID_ERC165 =
    bytes4(keccak256('supportsInterface(bytes4)'));

  bytes4 constant InterfaceID_ERC721 =
    bytes4(keccak256('name()')) ^
    bytes4(keccak256('symbol()')) ^
    bytes4(keccak256('totalSupply()')) ^
    bytes4(keccak256('balanceOf(address)')) ^
    bytes4(keccak256('ownerOf(uint256)')) ^
    bytes4(keccak256('approve(address,uint256)')) ^
    bytes4(keccak256('transfer(address,uint256)')) ^
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^
    bytes4(keccak256('tweetsOfOwner(address)'));


  /*** DATA TYPES ***/

  struct Tweet {
    uint256 tweetId;
    string username;
    string tweet;
    string uri;
    address mintedBy;
    uint64 mintedAt;
  }


  /*** STORAGE ***/
    
  Tweet[] tweets;

  mapping (uint256 => address) public tweetIdToOwner;
  mapping (uint256 => uint256) tweetIdToIndex;
  mapping (address => uint256) ownershipTweetCount;
  mapping (uint256 => address) public tweetIdToApproved;

  mapping(bytes32 => string) internal queryToPost;
  mapping(bytes32 => string) public tweetTexts;


  /*** EVENTS ***/

  event Mint(address owner, uint256 tokenId);
  event LogInfo(string description);
  event LogTextUpdate(string text);
  event LogUpdate(address indexed _owner, uint indexed _balance);


  /*** INTERNAL FUNCTIONS ***/

  /* Functions */
  /// @notice The constuctor function for this contract, establishing the owner of the oracle, the intial balance of the contract, and the Oraclize Resolver address
  /// @dev Owner management can be done through Open-Zeppelin's Ownable.sol, this contract needs ETH to function and should be initialized with funds
  constructor()
  payable
  public
  {
      owner = msg.sender;

      emit LogUpdate(owner, address(this).balance);

      // Replace the next line with your version:
      OAR = OraclizeAddrResolverI(0x6f485C8BF6fc43eA212E93BBF8ce046C7f1cb475);

      oraclize_setProof(proofType_TLSNotary | proofStorage_IPFS);
  }

  /// @notice An internal function which checks that a particular string is not empty
  /// @dev To be used in the Oraclize callback function to make sure the resulting text is not null
  /// @param _s The string to check if empty/null
  /// @return Returns false if the string is empty, and true otherwise
  function stringNotEmpty(string _s)
  internal
  pure
  returns(bool)
  {
    bytes memory tempString = bytes(_s);
    if (tempString.length == 0) {
        return false;
    } else {
        return true;
    }
  } 

  /// @notice This function iniates the oraclize process for a Twitter post
  /// @dev This contract needs ether to be able to call the oracle, which is why this function is also payable
  /// @param _postId The twitter post to fetch with the oracle. Expecting "<user>/status/<id>"
  function oraclizeTweet(string _postId)
  public
  payable
  whenNotPaused
  {
      // Check if we have enough remaining funds
      if (oraclize_getPrice("URL") > address(this).balance) {
          emit LogInfo("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
      } else {
          emit LogInfo("Oraclize query was sent, standing by for the answer..");
          // Using XPath to to fetch the right element in the JSON response
          string memory query = string(abi.encodePacked("html(https://twitter.com/", _postId, ").xpath(//div[contains(@class, 'permalink-tweet-container')]//p[contains(@class, 'tweet-text')]//text())"));

          bytes32 queryId = oraclize_query("URL", query, 6721975);
          queryToPost[queryId] = _postId;
      }
  }

  /// @notice The callback function that Oraclize calls when returning a result
  /// @dev Will store the text of a Twitter post into this contract's storage
  /// @param _id The query ID generated when calling oraclize_query
  /// @param _result The result from Oraclize, should be the Twitter post text
  /// @param _proof The authenticity proof returned by Oraclize, not currently being used in this contract, but it can be upgraded to do so
  function __callback(bytes32 _id, string _result, bytes _proof)
  public
  whenNotPaused
  {
      require(
          msg.sender == oraclize_cbAddress(),
          "The caller of this function is not the offical Oraclize Callback Address."
          );
      require(
          stringNotEmpty(queryToPost[_id]),
          "The Oraclize query ID does not match an Oraclize request made from this contract."
          );

      bytes32 postHash = keccak256(abi.encodePacked(queryToPost[_id]));
      tweetTexts[postHash] = _result;

      // emit LogTextUpdate(_result);
  }  


  /* ERC721 Functions */

  function _owns(address _claimant, uint256 _tweetId) internal view returns (bool) {
    return tweetIdToOwner[_tweetId] == _claimant;
  }

  function _approvedFor(address _claimant, uint256 _tweetId) internal view returns (bool) {
    return tweetIdToApproved[_tweetId] == _claimant;
  }

  function _approve(address _to, uint256 _tweetId) internal {
    tweetIdToApproved[_tweetId] = _to;

    emit Approval(tweetIdToOwner[_tweetId], tweetIdToApproved[_tweetId], _tweetId);
  }

  function _transfer(address _from, address _to, uint256 _tweetId, uint256 _tokenId) internal {
    ownershipTweetCount[_to]++;
    tweetIdToOwner[_tweetId] = _to;
    tweetIdToIndex[_tweetId] = _tokenId;

    if (_from != address(0)) {
      ownershipTweetCount[_from]--;
      delete tweetIdToApproved[_tweetId];
    }

    emit Transfer(_from, _to, _tweetId);
  }

  function _mint(uint256 _tweetId, string _username, string _tweet, string _uri, address _owner) internal returns (uint256 tweetId) {
    require(tweetIdToOwner[_tweetId] == address(0), 'Tweet proof already exists');
    Tweet memory tweet = Tweet({
        tweetId: _tweetId,
        username: _username,
        tweet: _tweet,
        uri: _uri,
        mintedBy: _owner,
        mintedAt: uint64(now)
    });
    
    uint256 tokenId = tweets.push(tweet) - 1;
    tweetId = _tweetId;

    emit Mint(_owner, _tweetId);

    _transfer(0, _owner, tweetId, tokenId);
  }
  

  /*** ERC721 IMPLEMENTATION ***/

  function supportsInterface(bytes4 _interfaceID) external view returns (bool) {
    return ((_interfaceID == InterfaceID_ERC165) || (_interfaceID == InterfaceID_ERC721));
  }

  function totalSupply() public view returns (uint256) {
    return tweets.length;
  }

  function balanceOf(address _owner) public view returns (uint256) {
    return ownershipTweetCount[_owner];
  }

  function ownerOf(uint256 _tweetId) external view returns (address owner) {
    owner = tweetIdToOwner[_tweetId];

    require(owner != address(0));
  }

  function approve(address _to, uint256 _tweetId) external {
    require(_owns(msg.sender, _tweetId));

    _approve(_to, _tweetId);
  }

  function transfer(address _to, uint256 _tweetId) external {
    require(_to != address(0));
    require(_to != address(this));
    require(_owns(msg.sender, _tweetId));
    
    _transfer(msg.sender, _to, _tweetId, tweetIdToIndex[_tweetId]);
  }

  function transferFrom(address _from, address _to, uint256 _tweetId) external {
    require(_to != address(0));
    require(_to != address(this));
    require(_approvedFor(msg.sender, _tweetId));
    require(_owns(_from, _tweetId));

    _transfer(_from, _to, _tweetId, tweetIdToIndex[_tweetId]);
  }

  function tweetsOfOwner(address _owner) external view returns (uint256[]) {
    uint256 balance = balanceOf(_owner);

    if (balance == 0) {
      return new uint256[](0);
    } else {
      uint256[] memory result = new uint256[](balance);
      uint256 supply = totalSupply();
      uint256 idx = 0;

      uint256 tokenId;
      for (tokenId = 1; tokenId <= supply; tokenId++) {
        if (tweetIdToOwner[tokenId] == _owner) {
          result[idx] = tokenId;
          idx++;
        }
      }
    }

    return result;
  }


  /*** OTHER EXTERNAL FUNCTIONS ***/

  function mint(uint256 _tweetId, string _username, string _tweet, string _uri) external returns (uint256) {
    return _mint(_tweetId, _username, _tweet, _uri, msg.sender);
  }

  function getTweet(uint256 _tweetId) external view returns (uint256 tweetId, string username, string tweet, string uri, address mintedBy, uint64 mintedAt) {
      
    Tweet memory currentTweet = tweets[tweetIdToIndex[_tweetId]];

    tweetId = currentTweet.tweetId;
    username = currentTweet.username;
    tweet = currentTweet.tweet;
    uri = currentTweet.uri;
    mintedBy = currentTweet.mintedBy;
    mintedAt = currentTweet.mintedAt;
  }
}