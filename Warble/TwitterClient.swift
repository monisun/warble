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
        
        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "warble://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
            
            println("got the request token")
            var authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
            
            UIApplication.sharedApplication().openURL(authURL!)
            
            }) { (error: NSError!) -> Void in
                println("failed to get request token")
                self.loginCompletion?(user: nil, error: error)
        }
    }
    
    func openURL(url: NSURL) {
        
        fetchAccessTokenWithPath("oauth/access_token", method: "POST", requestToken: BDBOAuth1Credential(queryString: url.query), success: { (accessToken: BDBOAuth1Credential!) -> Void in
            println("got the access token")
            
            TwitterClient.sharedInstance.requestSerializer.saveAccessToken(accessToken)
            
            // verify credentials and get current user
            TwitterClient.sharedInstance.GET("1.1/account/verify_credentials.json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                
//                var dict = NSJSONSerialization.JSONObjectWithData(response! as! NSData, options: nil, error: nil) as! NSDictionary
                
                var user = User(dict: response as! NSDictionary)
                User.currentUser = user
                
                println("serialized user: \(user)")
                println("user: \(user.name)")
                
                self.loginCompletion?(user: user, error: nil)
                
                }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                    println("error getting current user")
                    self.loginCompletion?(user: nil, error: error)
            })
            
        }) { (error: NSError!) -> Void in
            println("failed to retrieve access token")
            self.loginCompletion?(user: nil, error: error!)
        }
    }
    
    func homeTimelineWithParams(params: NSDictionary?, completion: (tweets: [Tweet]?, error: NSError?) -> ()) {
        // get home timeline
        GET("1.1/statuses/home_timeline.json", parameters: nil, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
            
//            var homeTimelineAsJson = NSJSONSerialization.JSONObjectWithData(response! as? NSArray, options: nil, error: nil) as! [NSDictionary]
        
            println("home timeline: \(response as! [NSDictionary])")
            
            var tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            completion(tweets: tweets, error: nil)
            
        }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                println("error getting home timeline: \(error.description)")
                completion(tweets: nil, error: error)
        })
    }

}
