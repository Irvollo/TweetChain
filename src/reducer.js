import { combineReducers } from 'redux'
import { routerReducer } from 'react-router-redux'
import userReducer from './user/userReducer'
import priceReducer from './price/priceReducer'
import web3Reducer from './util/web3/web3Reducer'

const reducer = combineReducers({
  routing: routerReducer,
  user: userReducer,
  price: priceReducer,
  web3: web3Reducer
})

export default reducer
