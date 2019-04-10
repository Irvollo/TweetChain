import React, { Component } from 'react'
import PriceTickerContainer from '../../ui/priceTicker/PriceTickerContainer'

class Test extends Component {
  render() {
    return(
      <main className="container">
        <div className="pure-g">
          <div className="pure-u-1-1">
            <h1>Test</h1>
            <p>Test the Price Oracle.</p>
            <PriceTickerContainer />
          </div>
        </div>
      </main>
    )
  }
}

export default Test
