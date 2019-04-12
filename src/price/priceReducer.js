const initialState = {
    balance: 0,
    currentPrice: 0,
  }
  
  const priceReducer = (state = initialState, action) => {
    switch (action.type) {
      case 'CURRENT_BALANCE': 
        return Object.assign({}, state, {
          balance: action.balance
        })
      case 'SET_CURRENT_PRICE': 
        return Object.assign({}, state, {
          currentPrice: action.currentPrice
        })
      default:
        return state;
    }

  }
  
  export default priceReducer
  