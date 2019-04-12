import contract_tweetchain from '../../../../build/contracts/TweetChain.json';
import store from '../../../store'

const contract = require('truffle-contract')

export const SET_TOTAL_SUPPLY = 'SET_TOTAL_SUPPLY'
export const UPLOAD_TWEET = 'UPLOAD_TWEET'


function setTotalSupply(supply) {
    return {
      type: SET_TOTAL_SUPPLY,
      supply
    }
}

function uploadTweetSuccess() {
    return {
        type: UPLOAD_TWEET,
    }
}

export function getTotalSupply() {
    let web3 = store.getState().web3.web3Instance
    // Double-check web3's status.
    if (web3) {

        return function(dispatch) {
        // Using truffle-contract we create the authentication object.
        const TweetChainContract = contract(contract_tweetchain);
        TweetChainContract.setProvider(web3.currentProvider);

        console.log(TweetChainContract);
        // Declaring this for later so we can chain functions on Authentication.
        let tweetChainInstance

        // Get current ethereum wallet.
        web3.eth.getAccounts((error, accounts) => {
            // Log errors, if any.
            if (error) {
            console.error(error);
            }
            // const account = accounts[0];

            TweetChainContract.deployed().then(function(instance) {
                tweetChainInstance = instance;
                return tweetChainInstance.totalSupply.call();
              }).then(function(value) {
                const newValue = web3.fromWei(value.valueOf(), 'ether');
                dispatch(setTotalSupply(newValue));
              }).catch(function(e) {
                console.log(e);
                self.setStatus("Error getting total Supply; see console log.");
              });
            })
        }
    } else {
        console.error('Web3 is not initialized.');
    }
} 

export function uploadTweet(tweetId) {
    let web3 = store.getState().web3.web3Instance
    // Double-check web3's status.
    if (web3) {

        return function(dispatch) {
        // Using truffle-contract we create the authentication object.
        const TweetChainContract = contract(contract_tweetchain);
        TweetChainContract.setProvider(web3.currentProvider);

        console.log(TweetChainContract);
        // Declaring this for later so we can chain functions on Authentication.
        let tweetChainInstance

        // Get current ethereum wallet.
        web3.eth.getAccounts((error, accounts) => {
            // Log errors, if any.
            if (error) {
            console.error(error);
            }
            const account = accounts[0];

            TweetChainContract.deployed().then(function(instance) {
                tweetChainInstance = instance;

                /* TODO SEND TRANSACTION */
                // return tweetChainInstance.totalSupply.call();
                tweetChainInstance.oraclizeTweet('irvollo/status/1116509618249719808', {from:account, value:web3.toWei(0.1,'ether')})
              }).then(function(err,result) {
                console.log('Error:', err);
                console.log('Result:', result);
              }).catch(function(e) {
                console.log(e);
                self.setStatus("Error uploading new Tweet;");
              });
            })
        }
    } else {
        console.error('Web3 is not initialized.');
    }
}