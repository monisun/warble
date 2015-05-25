//
//  ComposeTweetViewController.swift
//  Warble
//
//  Created by Monica Sun on 5/22/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

class ComposeTweetViewController: UIViewController, UITextViewDelegate {
    
    var user = User(dict: NSDictionary())
    var replyToTweetId: Int?
    var tweetTextPrefix: String?
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenname: UILabel!
    
    @IBOutlet weak var characterCounterLabel: UILabel!
    @IBOutlet weak var tweetTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweetTextView.delegate = self
        
        if let userName = user.name as String? {
            if userName.isEmpty {
                NSLog("Current logged in user was not properly initialized in ComposeTweetViewController! User name is empty.")
            } else {
                // properly initialized; populate compose view
                profileImage.setImageWithURL(NSURL(string: user.profileImageUrl!))
                profileImage.contentMode = UIViewContentMode.ScaleAspectFill
                profileImage.frame.size.width = 30
                profileImage.frame.size.height = 30
                profileImage.layer.cornerRadius = 5
                
                nameLabel.text = user.name
                screenname.text = "@" + (user.username as String!)
                characterCounterLabel.text = "140"
                
                // styling
                nameLabel.textAlignment = NSTextAlignment.Left
                nameLabel.font = UIFont(name: "HelveticaNeue", size: 14)
                nameLabel.numberOfLines = 1
                screenname.textAlignment = NSTextAlignment.Left
                screenname.font = UIFont(name: "HelveticaNeue", size: 12)
                screenname.textColor = UIColor.darkGrayColor()
                screenname.numberOfLines = 1
                characterCounterLabel.textAlignment = NSTextAlignment.Right
                characterCounterLabel.font = UIFont(name: "HelveticaNeue", size: 12)
                characterCounterLabel.textColor = UIColor.darkGrayColor()
                characterCounterLabel.numberOfLines = 1
            }
        } else {
            NSLog("Current logged in user was not properly initialized in ComposeTweetViewController! User name is nil.")
        }
        
        if let prefix = tweetTextPrefix as String? {
            tweetTextView.text = prefix
        } else {
            tweetTextView.text = ""
        }
//        tweetTextView.clearsOnInsertion = true
        tweetTextView.layer.cornerRadius = 10
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
                // TODO further validation? if replyToTweetId is not nil, then tweet text must contain "@username" of referenced tweet.
                
                // save tweet
                SVProgressHUD.showProgress(1, status: "Loading...")
                TwitterClient.sharedInstance.tweetWithStatus(tweetText, replyToTweetId: replyToTweetId, completion: { (result, error) -> () in
                    if error != nil {
                        SVProgressHUD.dismiss()
                        NSLog("ERROR: TwitterClient.sharedInstance.tweetWithStatus: \(error)")
                    } else {
                        NSLog("Successfully posted new tweet.")
                        SVProgressHUD.showSuccessWithStatus("Success")
                        
                        if let replyId = self.replyToTweetId as Int?  {
                            // nav back to show tweet VC
                            self.dismissViewControllerAnimated(true, completion: nil)
                        } else {
                            // nav back to home timeline
                            let tweetViewController = self.presentingViewController as! TweetsViewController!
                            // TODO reloadData() did not always refresh correctly, as tweets[] was already populated before new tweet got to home timeline (?)
                            // tweetViewController.tableView.reloadData()
                            
                            SVProgressHUD.showProgress(1, status: "Loading...")
                            TwitterClient.sharedInstance.homeTimelineWithParams(nil, maxId: nil, completion: { (tweets, minId, error) -> () in
                                if error != nil {
                                    SVProgressHUD.dismiss()
                                    NSLog("ERROR: TwitterClient.sharedInstance.homeTimelineWithParams: \(error)")
                                } else {
                                    tweetViewController.tweets = tweets!
                                    tweetViewController.tableView.reloadData()
                                    tweetViewController.minId = minId
                                    SVProgressHUD.showSuccessWithStatus("Success")
                                    
                                    // segue back to main page
                                    self.performSegueWithIdentifier("tweetDoneSegue", sender: self)
                                }
                            })
                        }
                    }
                })
            }
        } else {
            NSLog("UNEXPECTED: tweetText is nil")
        }
    }
    
    @IBAction func onCancelButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return count(tweetTextView.text) + (count(text) - range.length) <= 140
    }
    
    func textViewDidChange(sender: UITextView) {
        if let charCount = count(tweetTextView.text) as Int? {
            let remaining = 140 - charCount
            characterCounterLabel.text = "\(remaining)"
        }
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

}
