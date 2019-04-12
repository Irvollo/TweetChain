const initialState = {
    supply: 100,
}

const tweetReducer = (state = initialState, action) => {
    console.log('action:', action);
    switch (action.type) {
        case 'SET_TOTAL_SUPPLY': 
            return Object.assign({}, state, {
                supply: action.supply
            })
        default:
            return state;
    }
}

export default tweetReducer
