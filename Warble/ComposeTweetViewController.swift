//
//  ComposeTweetViewController.swift
//  Warble
//
//  Created by Monica Sun on 5/22/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

class ComposeTweetViewController: UIViewController {
    
    var user = User(dict: NSDictionary())
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenname: UILabel!
    
    @IBOutlet weak var tweetTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userName = user.name as String? {
            if userName.isEmpty {
                NSLog("Current logged in user was not properly initialized in ComposeTweetViewController! User name is empty.")
            } else {
                // properly initialized; populate compose view
                profileImage.setImageWithURL(NSURL(string: user.profileImageUrl!))
                profileImage.contentMode = UIViewContentMode.ScaleAspectFit
                profileImage.frame.size.width = 25
                profileImage.frame.size.height = 50
                
                nameLabel.text = user.name
                screenname.text = "@" + (user.username as String!)
                // styling
                nameLabel.textAlignment = NSTextAlignment.Left
                nameLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
                nameLabel.numberOfLines = 1
                screenname.textAlignment = NSTextAlignment.Left
                screenname.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
                screenname.textColor = UIColor.darkGrayColor()
                screenname.numberOfLines = 1
            }
        } else {
            NSLog("Current logged in user was not properly initialized in ComposeTweetViewController! User name is nil.")
        }
        
        tweetTextView.clearsOnInsertion = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // TODO doesn't seem to do anything??
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        view.endEditing(true)
        super.touchesBegan(touches as Set<NSObject>, withEvent: event)
    }
    
    
    @IBAction func onTweetButtonClick(sender: AnyObject) {
        let emptyTweetAlert = UIAlertController(title: "Empty Tweet", message: "Tweets cannot be empty!",  preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        emptyTweetAlert.addAction(okAction)
        
        // validate tweet
        if let tweetText = tweetTextView.text as String? {
            if tweetText.isEmpty {
                self.presentViewController(emptyTweetAlert, animated: false, completion: nil)
            } else {
                // TODO further validation?
                
                // save tweet
                TwitterClient.sharedInstance.tweetWithStatus(tweetText, completion: { (result, error) -> () in
                    if error != nil {
                        NSLog("ERROR: TwitterClient.sharedInstance.tweetWithStatus: \(error)")
                    } else {
                        NSLog("Successfully posted new tweet with result: \(result)")
                        let tweetViewController = self.presentingViewController as! TweetsViewController!
                        // TODO reloadData() did not always refresh correctly, as tweets[] was already populated before new tweet got to home timeline (?)
//                        tweetViewController.tableView.reloadData()
                        
                        TwitterClient.sharedInstance.homeTimelineWithParams(nil, completion: { (tweets, error) -> () in
                            if error != nil {
                                NSLog("ERROR: TwitterClient.sharedInstance.homeTimelineWithParams: \(error)")
                            } else {
                                tweetViewController.tweets = tweets!
                                tweetViewController.tableView.reloadData()
                            }
                        })

                    }
                })
                
                // segue back to main page
                performSegueWithIdentifier("tweetDoneSegue", sender: self)
                
                
            }
        } else {
            NSLog("UNEXPECTED: tweetText is nil")
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        if segue.identifier == "tweetDoneSegue" {
//            
//        }
    }

}
