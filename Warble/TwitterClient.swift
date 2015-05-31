//
//  TwitterClient.swift
//  Warble
//
//  Created by Monica Sun on 5/20/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

// TODO store in plist
let twitterConsumerKey = "EprTm2EfvGFT21BnsUNZyOd0r"
let twitterConsumerSecret = "syq358u0WF9HCeeGKLuvqTwf6gwihrNLkrLQebmwam6TyGxDar"
let twitterBaseURL = NSURL(string: "https://api.twitter.com")

class TwitterClient: BDBOAuth1RequestOperationManager {
    
    var loginCompletion: ((user: User?, error: NSError?) -> ())?
    
    class var sharedInstance: TwitterClient {
        struct Static {
            static let instance =  TwitterClient(baseURL: twitterBaseURL, consumerKey: twitterConsumerKey, consumerSecret: twitterConsumerSecret)
        }
        return Static.instance
    }
    
    func loginWithCompletion(completion: (user: User?, error: NSError?) -> ()) {
        loginCompletion = completion
        
        // fetch request token & redirect to authorization page 
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "warble://oauth"), scope: nil,
            success: { (requestToken: BDBOAuth1Credential!) -> Void in
                NSLog("Successfully got the request token.")
                
                var authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
                UIApplication.sharedApplication().openURL(authURL!)
            }) { (error: NSError!) -> Void in
                NSLog("Error getting request token.")
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func openURL(url: NSURL) {
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query),
            success: { (accessToken: BDBOAuth1Credential!) -> Void in
                NSLog("Successfully got the access token.")
                TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
                
                // verify credentials and get current user
                TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil,
                    success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                        //                var dict = NSJSONSerialization.JSONObjectWithData(response! as! NSData, options: nil, error: nil) as! NSDictionary
                        var user = User(dict: response as! NSDictionary)
                        User.currentUser = user
                        
                        NSLog("Successfully serialized user: \(user) with username: \(user.name)")
                        
                        self.loginCompletion?(user: user, error: nil)},
                    failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                        NSLog("Error getting current user.")
                        self.loginCompletion?(user: nil, error: error)
                })
            
        }) { (error: NSError!) -> Void in
            NSLog("Failed to retrieve access token/")
            self.loginCompletion?(user: nil, error: error!)
        }
    }
    
    func homeTimelineWithParams(params: NSDictionary?, maxId: Int?, completion: (tweets: [Tweet]?, minId: Int?, error: NSError?) -> ()) {
        // get home timeline
        var homeTimelineUrl = "1.1/statuses/home_timeline.json?count=100"   // 200 is max
        
        if let maxId = maxId as Int! {
            homeTimelineUrl += "&max_id=\(maxId)"
        }
        homeTimelineUrl = homeTimelineUrl.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        GET(homeTimelineUrl, parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                //          var homeTimelineAsJson = NSJSONSerialization.JSONObjectWithData(response! as? NSArray, options: nil, error: nil) as! [NSDictionary]
                NSLog("Successfully got home timeline.")
                
                // debug
//                println(response)
//                let path = NSBundle.mainBundle().pathForResource("hometimeline", ofType: "json")
//                response.writeToFile(path!, options: NSDataWritingOptions.DataWritingFileProtectionCompleteUnlessOpen, error: nil)
                
                var tweetsData = Tweet.tweetsWithArray(response as! [NSDictionary]) as ([Tweet], Int)
                var tweets = tweetsData.0
                var minId = tweetsData.1
                completion(tweets: tweets, minId: minId, error: nil)},
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                NSLog("Error getting home timeline: \(error.description)")
                completion(tweets: nil, minId: nil, error: error)
        })
    }
    
    
    func tweetWithStatus(status: String, replyToTweetId: Int?, completion: (result: NSDictionary?, error: NSError?) -> ()) {
        var tweetJSONUrl = "1.1/statuses/update.json?status=" + status
        
        if let replyToId = replyToTweetId as Int? {
            tweetJSONUrl = tweetJSONUrl + "&in_reply_to_status_id=\(replyToId)"
        }
        
        tweetJSONUrl = tweetJSONUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        POST(tweetJSONUrl, parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                NSLog("Successfully tweeted with status.")
                completion(result: response as? NSDictionary, error: nil)},
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                NSLog("Error posting new tweet: \(error.description)")
                completion(result: nil, error: error)
        })
    }
    
    func retweet(id: Int, completion: (result: NSDictionary?, error: NSError?) -> ()) {
        var retweetJSONUrl = "1.1/statuses/retweet/\(id).json"
        retweetJSONUrl = retweetJSONUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        POST(retweetJSONUrl, parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                NSLog("Successfully retweeted a tweet.")
                completion(result: response as? NSDictionary, error: nil)},
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                NSLog("Error retweeting: \(error.description)")
                completion(result: nil, error: error)
        })
    }
    
    func destroy(id: Int, completion: (result: NSDictionary?, error: NSError?) -> ()) {
        var retweetJSONUrl = "1.1/statuses/destroy/\(id).json"
        retweetJSONUrl = retweetJSONUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        POST(retweetJSONUrl, parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                NSLog("Successfully destroyed a tweet.")
                completion(result: response as? NSDictionary, error: nil)},
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                NSLog("Error destroying tweet: \(error.description)")
                completion(result: nil, error: error)
        })
    }
    
    func createFavorite(id: Int, completion: (result: NSDictionary?, error: NSError?) -> ()) {
        var createFavoriteJSONUrl = "1.1/favorites/create.json?id=\(id)"
        createFavoriteJSONUrl = createFavoriteJSONUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        POST(createFavoriteJSONUrl, parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                NSLog("SUCCESS: Request create favorite.")
                completion(result: response as? NSDictionary, error: nil)},
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                NSLog("Error in create favorite: \(error.description)")
                completion(result: nil, error: error)
        })
    }
    
    func destroyFavorite(id: Int, completion: (result: NSDictionary?, error: NSError?) -> ()) {
        var destroyFavoriteJSONUrl = "1.1/favorites/destroy.json?id=\(id)"
        destroyFavoriteJSONUrl = destroyFavoriteJSONUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        POST(destroyFavoriteJSONUrl, parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                NSLog("SUCCESS: Request destroy favorite.")
                completion(result: response as? NSDictionary, error: nil)},
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                NSLog("Error in destroy favorite: \(error.description)")
                completion(result: nil, error: error)
        })
    }
    
    func searchTweets(q: String, completion: (tweets: [Tweet]?, minId: Int?, error: NSError?) -> ()) {
        // search for top 20 tweets
        var trimmedQ = q.stringByReplacingOccurrencesOfString(" ", withString: "")
        var searchUrl = "1.1/search/tweets.json?q=\(trimmedQ)&count=20"
        searchUrl = searchUrl.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        GET(searchUrl, parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                NSLog("Successfully got search results home timeline.")
                
                var tweetsData = Tweet.tweetsWithArray(response["statuses"] as! [NSDictionary]) as ([Tweet], Int)
                var tweets = tweetsData.0
                var minId = tweetsData.1
                completion(tweets: tweets, minId: minId, error: nil)},
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                NSLog("Error getting home timeline: \(error.description)")
                completion(tweets: nil, minId: nil, error: error)
        })
    }
    
    func profileBannerForUser(userName: String, completion: (url: String?, error: NSError?) -> ()) {
        // DEBUG test data
//        let url = "https://pbs.twimg.com/profile_banners/42220353/1418990349/mobile"
//        completion(url: url, error: nil)
        
        // get profile banner for user
        var profileBannerUrl = "1.1/users/profile_banner.json?screen_name=\(userName)"
        
        profileBannerUrl = profileBannerUrl.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        GET(profileBannerUrl, parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                NSLog("Successfully got profile banner.")
                
                if let result = response as? NSDictionary {
                    if let sizes = result["sizes"] as? NSDictionary {
                        if let mobile = sizes["mobile"] as? NSDictionary {
                            if let url = mobile["url"] as? String {
                                //debug
                                println("url")
                                println(url)
                                completion(url: url, error: nil)
                            }
                        }
                    }
                }
            },
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                NSLog("Error getting profile banner: \(error.description)")
                completion(url: nil, error: error)
        })
    }
    
    func userTimelineWithParams(username: String, maxId: Int?, completion: (tweets: [Tweet]?, minId: Int?, error: NSError?) -> ()) {
        // get user timeline
        var userTimelineUrl = "1.1/statuses/user_timeline.json?count=50&screen_name=\(username)"
        
        if let maxId = maxId as Int! {
            userTimelineUrl += "&max_id=\(maxId)"
        }
        
        userTimelineUrl = userTimelineUrl.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        GET(userTimelineUrl, parameters: nil,
            success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                NSLog("Successfully got user timeline.")
                
                // debug
//                println(response)
                
                var tweetsData = Tweet.tweetsWithArray(response as! [NSDictionary]) as ([Tweet], Int)
                var tweets = tweetsData.0
                var minId = tweetsData.1
                completion(tweets: tweets, minId: minId, error: nil)},
            failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                NSLog("Error getting home timeline: \(error.description)")
                completion(tweets: nil, minId: nil, error: error)
        })
    }
    
    // test data
//    private func test_hometimeline_data() -> NSArray {
//        let path = NSBundle.mainBundle().pathForResource("hometimeline", ofType: "json")
//        let jsonData = NSData(contentsOfFile: path!)
//        var jsonResult: NSArray = NSJSONSerialization.JSONObjectWithData(jsonData!, options: NSJSONReadingOptions.MutableContainers, error: nil) as! NSArray
//        return jsonResult
//    }
}
