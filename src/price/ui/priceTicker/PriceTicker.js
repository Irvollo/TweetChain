import React, { Component } from 'react'

class PriceTicker extends Component {
  constructor(props) {
    super(props)

    this.state = {
      
    }
  }

  componentDidMount = () => {
      const {getBalance,initEventListeners} = this.props;
      setTimeout(initEventListeners, 1000);
      setTimeout(getBalance, 1000)
  }

  render() {
    const { balance, currentPrice } = this.props;
    return(
      <div>
          <h1>Current Balance</h1>
          <h3>{balance} Ξ ({balance * currentPrice} USD)</h3>
          <h3>@{currentPrice} USD</h3>
      </div>
    )
  }
}

export default PriceTicker
