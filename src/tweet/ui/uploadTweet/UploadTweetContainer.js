import { connect } from 'react-redux'
import UploadTweet from './UploadTweet'
import { getTotalSupply, uploadTweet } from './UploadTweetActions'

const mapStateToProps = (state, ownProps) => {
  return {
    supply: state.tweet.supply,
  }
}

const mapDispatchToProps = (dispatch) => {
  return {
    getTotalSupply: () => {
      dispatch(getTotalSupply())
    },
    uploadTweet: (tweetId) => {
      dispatch(uploadTweet(tweetId))
    }
  }
}

const UploadTweetContainer = connect(
  mapStateToProps,
  mapDispatchToProps
)(UploadTweet)

export default UploadTweetContainer
