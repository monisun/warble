//
//  User.swift
//  Warble
//
//  Created by Monica Sun on 5/21/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

var _currentUser: User?

let currentUserKey = "kCurrentUserKey"
let userDidLogInNotification = "userDidLogInNotification"
let userDidLogOutNotification = "userDidLogOutInNotification"

class User: NSObject {
    
    var name: String?
    var username: String?
    var profileImageUrl: String?
    var tagline: String?
    
    var dict: NSDictionary
    
    init(dict: NSDictionary) {
        self.dict = dict
        name = dict["name"] as? String
        username = dict["screen_name"] as? String
        profileImageUrl = dict["profile_image_url"] as? String
        tagline = dict["description"] as? String
    }
    
    class var currentUser: User? {
        get {
            if _currentUser == nil {
                var data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
                if data != nil {
                    var dict = NSJSONSerialization.JSONObjectWithData(data!, options: nil, error: nil) as! NSDictionary
                    _currentUser = User(dict: dict)
                }
            }
        
            return _currentUser
        }
        set(user) {
            _currentUser = user
            
            if _currentUser != nil {
                var data = NSJSONSerialization.dataWithJSONObject(user!.dict, options: nil, error: nil)
                NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
            } else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            }
            
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    func logout() {
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogOutNotification, object: nil)
    }
   
}
