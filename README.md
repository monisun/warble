# Warble
Simple Twitter client to read and compose tweets using the [Twitter API](https://apps.twitter.com/).

Time spent: `<Number of hours spent>`

### Features

#### Required

- [x] User can sign in using OAuth login flow
- [x] User can view last 20 tweets from their home timeline
- [x] The current signed in user will be persisted across restarts
- [x] In the home timeline, user can view tweet with the user profile picture, username, tweet text, and timestamp.  In other words, design the custom cell with the proper Auto Layout settings.  You will also need to augment the model classes.
- [x] User can pull to refresh
- [x] User can compose a new tweet by tapping on a compose button.
- [x] User can tap on a tweet to view it, with controls to retweet, favorite, and reply.
- [x] User can retweet, favorite, and reply to the tweet directly from the timeline feed.

#### Optional

- [x] When composing, you should have a countdown in the upper right for the tweet limit.
- [x] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
- [x] Retweeting and favoriting should increment the retweet and favorite count.
- [x] User should be able to unretweet and unfavorite and should decrement the retweet and favorite count.
- [x] Replies should be prefixed with the username and the reply_id should be set when posting the tweet,
- [x] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.

#### Additional

- [x] Added in-memory cache functionality to limit Twitter API home timeline requests. (Used as a workaround for API's low rate-limit.) Added handling to clear cache in case of low-memory warning.
- [x] Added different Reply, Retweet, Favorite button displays for Normal, Highlighted, vs Selected control states.
- [x] Added HUD to show loading/success state for API requests.


### Walkthrough

![Video Walkthrough](...)

### References
- [Twitter API](https://apps.twitter.com/)
- [BDBOAuth1Manager](https://github.com/bdbergeron/BDBOAuth1Manager)
- [AFNetworking](https://github.com/AFNetworking/AFNetworking)
- [SVProgressHUD](https://github.com/TransitApp/SVProgressHUD)
