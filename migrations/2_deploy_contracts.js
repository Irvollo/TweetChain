var OraclizeTest = artifacts.require("./OraclizeTest.sol");
var TweetChain = artifacts.require("./TweetChain.sol");

module.exports = function(deployer, network, accounts) {
  // Deploys the OraclizeTest contract and funds it with 0.5 ETH
  // The contract needs a balance > 0 to communicate with Oraclize
  /*deployer.deploy(
    OraclizeTest,
    { from: accounts[9], gas:6721975, value: 500000000000000000 }); */
    deployer.deploy(
      TweetChain,
      { from: accounts[9], gas:6721975, value: 500000000000000000 });
};