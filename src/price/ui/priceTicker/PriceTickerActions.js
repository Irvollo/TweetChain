import contract_build_artifacts from '../../../../build/contracts/OraclizeTest.json';
import store from '../../../store'

const contract = require('truffle-contract')

export const CURRENT_BALANCE = 'CURRENT_BALANCE'

function currentBalance(balance) {
    return {
      type: CURRENT_BALANCE,
      balance
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
                oraclizeInstance = instance

            // TODO Get Price
                oraclizeInstance.getBalance.call(account, {from: account})
                .then((balance) => {
                // If no error, update user.
                const newBalance = web3.fromWei(balance.toNumber(), "ether" );
                console.log(balance, account, newBalance)
                dispatch(currentBalance(newBalance))

                })
                .catch(function(result) {
                // If error...
                    console.log('Error getting balance')
                })
            })
        })
        }
    } else {
        console.error('Web3 is not initialized.');
    }
}
