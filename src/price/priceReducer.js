const initialState = {
    balance: 0
  }
  
  const priceReducer = (state = initialState, action) => {
    switch (action.type) {
      case 'CURRENT_BALANCE': 
        return Object.assign({}, state, {
          balance: action.balance
        })
      default:
        return state;
    }

  }
  
  export default priceReducer
  