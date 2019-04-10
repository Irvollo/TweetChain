pragma solidity ^0.4.18;

import "./internals/ERC721.sol";
import "installed_contracts/oraclize-api/contracts/usingOraclize.sol";

contract TweetChain is ERC721, usingOraclize {
  /*** CONSTANTS ***/

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


  /*** EVENTS ***/

  event Mint(address owner, uint256 tokenId);


  /*** INTERNAL FUNCTIONS ***/

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