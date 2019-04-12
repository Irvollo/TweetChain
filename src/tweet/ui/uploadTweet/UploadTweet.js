import React, { Component } from 'react'

class UploadTweet extends Component {
  constructor(props) {
    super(props)

    this.state = {
      
    }
  }

  componentDidMount = () => {
      const {getTotalSupply, uploadTweet} = this.props;
      setTimeout(getTotalSupply, 1500);
      setTimeout(uploadTweet, 1500);
  }

  render() {
    const {supply} = this.props;
    return(
      <div>
          <h1>Main Page</h1>
          <h3>Supply: {supply}</h3>
      </div>
    )
  }
}

export default UploadTweet
