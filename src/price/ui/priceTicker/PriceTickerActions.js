import contract_build_artifacts from '../../../../build/contracts/OraclizeTest.json';
import store from '../../../store'

const contract = require('truffle-contract')

export const CURRENT_BALANCE = 'CURRENT_BALANCE'
export const SET_CURRENT_PRICE = 'SET_CURRENT_PRICE'

function currentBalance(balance) {
    return {
      type: CURRENT_BALANCE,
      balance
    }
  }

function setCurrentPrice(currentPrice) {
    return {
      type: SET_CURRENT_PRICE,
      currentPrice
    }
  }

export function getBalance() {
    let web3 = store.getState().web3.web3Instance
    // Double-check web3's status.
    if (web3) {

        return function(dispatch) {
        // Using truffle-contract we create the authentication object.
        const OraclizeContract = contract(contract_build_artifacts);
        OraclizeContract.setProvider(web3.currentProvider)

        // Declaring this for later so we can chain functions on Authentication.
        let oraclizeInstance

        // Get current ethereum wallet.
        web3.eth.getAccounts((error, accounts) => {
            // Log errors, if any.
            if (error) {
            console.error(error);
            }
            const account = accounts[0];

            OraclizeContract.deployed().then(function(instance) {
                oraclizeInstance = instance;
                  
                return oraclizeInstance.getBalance.call(account, {from: account});
              }).then(function(value) {
                const balance = web3.fromWei(value.valueOf(), 'ether');
                dispatch(currentBalance(balance));
              }).catch(function(e) {
                console.log(e);
                self.setStatus("Error getting balance; see console log.");
              });
            })
        }
    } else {
        console.error('Web3 is not initialized.');
    }
}

export function initEventListeners() {
    let web3 = store.getState().web3.web3Instance
    // Double-check web3's status.
    if (web3) {

        return function(dispatch) {
        // Using truffle-contract we create the authentication object.
        const OraclizeContract = contract(contract_build_artifacts);
        OraclizeContract.setProvider(web3.currentProvider)

        // Declaring this for later so we can chain functions on Authentication.
        let oraclizeInstance

        OraclizeContract.deployed().then(function(instance) {
            oraclizeInstance = instance;
            //var LogCreated = instance.LogUpdate({},{fromBlock: 0, toBlock: 'latest'});
            var LogPriceUpdate = oraclizeInstance.LogPriceUpdate({},{fromBlock: 0, toBlock: 'latest'});
            // var LogInfo = instance.LogInfo({},{fromBlock: 0, toBlock: 'latest'});

            LogPriceUpdate.watch(function(err, result){
                if(!err){
                    console.log(result.args);
                    const {price} = result.args;
                    dispatch(setCurrentPrice(price));
                }else{
                    console.log(err)
                }
            })
          }).catch(function(e) {
            console.log(e);
            self.setStatus("Error getting balance; see console log.");
          });
        }
    } else {
        console.error('Web3 is not initialized.');
    }
}