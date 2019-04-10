import React, { Component } from 'react'

class PriceTicker extends Component {
  constructor(props) {
    super(props)

    this.state = {
      
    }
  }

  componentDidMount = () => {
      const {getBalance} = this.props;
      setInterval(getBalance, 1500)
  }

  render() {
    const { balance } = this.props;
    return(
      <div>
          <h1>Ticker</h1>
          <h3>{balance}</h3>
      </div>
    )
  }
}

export default PriceTicker
