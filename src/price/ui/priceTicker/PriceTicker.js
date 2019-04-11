import React, { Component } from 'react'

class PriceTicker extends Component {
  constructor(props) {
    super(props)

    this.state = {
      
    }
  }

  componentDidMount = () => {
      const {getBalance} = this.props;
      setTimeout(getBalance, 5000)
  }

  render() {
    const { balance } = this.props;
    return(
      <div>
          <h1>Current Balance</h1>
          <h3>{balance} Ξ</h3>
      </div>
    )
  }
}

export default PriceTicker
