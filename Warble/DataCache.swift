//
//  DataCache.swift
//  Warble
//
//  Created by Monica Sun on 5/23/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import CoreData

class DataCache {
    
    let delegate = UIApplication.sharedApplication().delegate as! AppDelegate
    let context = NSManagedObjectContext()
    
    func saveTweetsToCache(tweets: [Tweet]) -> Void {
        
        let cachedData = NSEntityDescription.insertNewObjectForEntityForName("TwitterData", inManagedObjectContext: context) as! NSManagedObject
        cachedData.setValue(tweets, forKey: "tweets")
        cachedData.setValue(NSDate(), forKey: "timestamp")
        
        var error: NSError?
        let success = context.save(&error)
        if success {
            NSLog("Failed to save tweets to cache.")
        } else {
            NSLog("Successfully saved tweets to cache.")
        }
    }
    
    func fetchTweeetsFromCache() -> [Tweet]? {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("TwitterData", inManagedObjectContext: context)
        fetchRequest.entity = entity

        var error: NSError?
        let optionalResult = context.executeFetchRequest(fetchRequest, error: &error) as! [NSManagedObject]

        if let result = optionalResult as [NSManagedObject]? {
            if let first = result[0] as NSManagedObject? {
                if let tweets = first.valueForKey("tweets") as? [Tweet] {
                    return tweets
                } else {
                    NSLog("UNEXPECTED: Cache did not contain any tweets.")
                    return nil
                }
            } else {
                NSLog("UNEXPECTED: Cache did not contain any tweets.")
                return nil
            }
        } else {
            NSLog("UNEXPECTED: Cache did not contain any tweets.")
            return nil
        }
    }
    
}


