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
    }

}

