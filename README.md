### Warble Redux

Time spent: `21 hrs`

### Features

#### Required
- [x] Hamburger menu
  - [x] Dragging anywhere in the view should reveal the menu.
  - [x] The menu should include links to your profile, the home timeline, and the mentions view.
  - [x] The menu can look similar to the LinkedIn menu.
- [x] Profile page
  - [x] Contains a section with the users basic stats: # tweets, # following, # followers 
  - [x] Contains the user header view
- [x] Home Timeline
  - [x] Tapping on a user image should bring up that user's profile page

#### Optional
- [x] Profile page
  - [x] Pulling down the profile page should blur and resize the header image.
  - [x] Implement the paging view for the user description.
  - [x] As the paging view moves, increase the opacity of the background screen. See the actual Twitter app for this effect

#### Additional
- [x] Added media content support for creating tweets. (See 2nd gif below taken on device: Using iPhone camera to take a pic and display image preview from Tweet Composer. *Note: Twitter API to upload media returned 503 Service Unavailable.)

### Walkthrough
<img src="https://github.com/monisun/warble/blob/redux/redux_hamburger_menu.gif" width="250px"/>
<img src="http://share.gifyoutube.com/Kke3jq.gif" width="250px"/>
<img src="https://github.com/monisun/warble/blob/redux/redux_hamburger_menu2.gif" width="250px"/>


# <img src="https://github.com/monisun/warble/blob/master/logo.png" height="300" width="300">
Simple Twitter client to view and compose tweets using the [Twitter API](https://apps.twitter.com/).

Time spent: `20 hrs`

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

- [x] Added in-memory cache functionality to limit Twitter API requests. (Used as a workaround for API's low rate-limit.) Added handling to clear cache in the case of low memory.
- [x] Added search bar to allow users to search for tweets.
- [x] Added media content (images) to tweets.
- [x] Added delete tweet functionality.
- [x] Added timestamp display formatting to show _time_ _ago_ similar to Twitter.
- [x] Added different Reply, Retweet, Favorite button displays for Normal, Highlighted, vs Selected control states.
- [x] Added HUD to show loading/success state for API requests.
- [x] Added facebook share integration for tweets.



### Walkthrough
*TL: OAuth login; home timeline. TR: fb share integration. BL: Search via Twitter Search API. BR: Tweet composer.*

<img src="https://github.com/monisun/warble/blob/master/demo_loginoauth_hometimeline.gif" width="300px"/>
<img src="https://github.com/monisun/warble/blob/master/demo_fbshare.gif" width="300px"/>
<img src="https://github.com/monisun/warble/blob/master/demo_searchbar.gif" width="300px"/>
<img src="https://github.com/monisun/warble/blob/master/demo_tweetcomposer.gif" width="300px"/>

### References
- [Twitter API](https://apps.twitter.com/)
- [BDBOAuth1Manager](https://github.com/bdbergeron/BDBOAuth1Manager)
- [AFNetworking](https://github.com/AFNetworking/AFNetworking)
- [SVProgressHUD](https://github.com/TransitApp/SVProgressHUD)
- [DateTools](https://github.com/MatthewYork/DateTools)

### License
Copyright (c) 2015 Monica Sun

Licensed under the MIT license.
