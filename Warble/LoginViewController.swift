//
//  ViewController.swift
//  Warble
//
//  Created by Monica Sun on 5/20/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit



class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onLogin(sender: AnyObject) {
        TwitterClient.sharedInstance.loginWithCompletion() {
            (user: User?, error: NSError?) in
            if error != nil {
                NSLog("ERROR: \(error)")
            } else {
                if user != nil {
                    // perform segue
                    self.performSegueWithIdentifier("loginSegue", sender: self)
                } else {
                    // handle login error
                    NSLog("ERROR: User is nil in onLogin")
                }
            }
        }
        
//        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        
//        TwitterClient.sharedInstance.fetchRequestTokenWithPath("oauth/request_token", method: "GET", callbackURL: NSURL(string: "warble://oauth"), scope: nil, success: { (requestToken: BDBOAuth1Credential!) -> Void in
//        
//            println("got the request token")
//            var authURL = NSURL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)")
//            
//            UIApplication.sharedApplication().openURL(authURL!)
//            
//            }) { (error: NSError!) -> Void in
//                println("failed to get request token")
//            }
    
    }


}

