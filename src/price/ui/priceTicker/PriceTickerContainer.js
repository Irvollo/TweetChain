import { connect } from 'react-redux'
import PriceTicker from './PriceTicker'
import { getBalance, initEventListeners } from './PriceTickerActions'

const mapStateToProps = (state, ownProps) => {
  return {
    balance: state.price.balance,
    currentPrice: state.price.currentPrice,
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    getBalance: () => {
      dispatch(getBalance())
    },
    initEventListeners: () => {
      dispatch(initEventListeners())
    }
  }
}

const PriceTickerContainer = connect(
  mapStateToProps,
  mapDispatchToProps
)(PriceTicker)

export default PriceTickerContainer
