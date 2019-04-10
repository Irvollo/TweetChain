import { connect } from 'react-redux'
import PriceTicker from './PriceTicker'
import { getBalance } from './PriceTickerActions'

const mapStateToProps = (state, ownProps) => {
  return {
    balance: state.price.balance
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    getBalance: () => {
      dispatch(getBalance())
    }
  }
}

const PriceTickerContainer = connect(
  mapStateToProps,
  mapDispatchToProps
)(PriceTicker)

export default PriceTickerContainer
