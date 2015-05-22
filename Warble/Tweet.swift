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
    
    let formatter = NSDateFormatter()
    
    init(dict: NSDictionary) {
        user = User(dict: dict["user"] as! NSDictionary)
        text = dict["text"] as? String
        createdAtString = dict["created_at"] as? String
        
        formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        createdAt = formatter.dateFromString(createdAtString!)
    }
    
    class func tweetsWithArray(array: [NSDictionary]) -> [Tweet] {
        var tweets = [Tweet]()
        
        for dict in array {
            tweets.append(Tweet(dict: dict))
        }
        
        return tweets
    }
   
}
