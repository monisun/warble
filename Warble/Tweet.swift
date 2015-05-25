//
//  Tweet.swift
//  Warble
//
//  Created by Monica Sun on 5/21/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    var user: User?
    var text: String?
    var createdAtString: String?
    var createdAt: NSDate?
    var tweetId: Int?
    var favoriteCount: Int?
    var retweetCount: Int?
    var mediaUrl: String?
    
    let formatter = NSDateFormatter()
    
    init(dict: NSDictionary) {
        user = User(dict: dict["user"] as! NSDictionary)
        tweetId = dict["id"] as? Int
        text = dict["text"] as? String
        createdAtString = dict["created_at"] as? String
        
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
        
        // display format
        formatter.dateFormat = "EEE MMM d HH:mm"
        createdAtString = formatter.stringFromDate(createdAt!)
        favoriteCount = dict["favorite_count"] as? Int
        retweetCount = dict["retweet_count"] as? Int
        
        if let entities = dict["entities"] as? NSDictionary {
            if let media = entities["media"] as? NSArray {
                if let firstMedia = media[0] as? NSDictionary {
                    if let mediaHttpsUrl = firstMedia["media_url_https"] as? String {
                        mediaUrl = mediaHttpsUrl
                    }
                }
            }
        }
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> ([Tweet], Int) {
        if array.count > 0 {
            let firstTweetInArray = Tweet(dict: array[0])
            
            // initialize minId as id of first Tweet in array
            var minId = firstTweetInArray.tweetId     // lowest id of tweets in array. maxId is an inclusive parameter per Twitter API; lower maxId means older tweet
            
            var tweets = [Tweet]()
            
            for entry in array {
                let currentTweet = Tweet(dict: entry)
                tweets.append(currentTweet)
                
                if currentTweet.tweetId < minId {
                    minId = currentTweet.tweetId
                }
            }
            return (tweets, minId!)
        } else {
            NSLog("array is empty in tweetsWithArray")
            return ([Tweet](), Int())
        }
    }
   
}
