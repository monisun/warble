//
//  ShowTweetViewController.swift
//  Warble
//
//  Created by Monica Sun on 5/22/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

class ShowTweetViewController: UIViewController {
    
    var tweet: Tweet?
    var tweetId: Int?
    var retweetId: Int?
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var favoriteCount: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // default reply, retweet and favorite buttons to not selected
        retweetButton.selected = false
        retweetButton.setImage(UIImage(named: "retweet"), forState: UIControlState.Normal)
        retweetButton.setImage(UIImage(named: "retweet_on"), forState: UIControlState.Selected)
        retweetButton.setImage(UIImage(named: "retweet_hover"), forState: UIControlState.Highlighted)
        
        favoriteButton.selected = false
        favoriteButton.setImage(UIImage(named: "favorite"), forState: UIControlState.Normal)
        favoriteButton.setImage(UIImage(named: "favorite_on"), forState: UIControlState.Selected)
        favoriteButton.setImage(UIImage(named: "favorite_hover"), forState: UIControlState.Highlighted)
        
        replyButton.selected = false
        replyButton.setImage(UIImage(named: "reply"), forState: UIControlState.Normal)
        replyButton.setImage(UIImage(named: "reply_hover"), forState: UIControlState.Selected)
        
        // hide by default
        deleteButton.hidden = true
        deleteButton.selected = false
        deleteButton.setImage(UIImage(named: "trash"), forState: UIControlState.Normal)
    
        if let tweet = tweet as Tweet? {
            let user = tweet.user as User?
            let urlString = user?.profileImageUrl as String?
            profileImage.setImageWithURL(NSURL(string: urlString!))
            nameLabel.text = user?.name
            screennameLabel.text = "@" + (user?.username as String!)
            tweetTextLabel.text = tweet.text
//            timestampLabel.text = tweet.createdAtString
            timestampLabel.text = tweet.createdAt!.shortTimeAgoSinceNow()
            tweetId = tweet.tweetId as Int?
            
            
            retweetCount.text = String(tweet.retweetCount as Int!)
            favoriteCount.text = String(tweet.favoriteCount as Int!)
            
            // styling
            // styling
            nameLabel.textAlignment = NSTextAlignment.Left
            nameLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
            nameLabel.numberOfLines = 1
            
            screennameLabel.textAlignment = NSTextAlignment.Left
            screennameLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
            screennameLabel.textColor = UIColor.darkGrayColor()
            screennameLabel.numberOfLines = 1
            
            tweetTextLabel.textAlignment = NSTextAlignment.Left
            tweetTextLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 14)
            tweetTextLabel.numberOfLines = 0
            
            timestampLabel.textAlignment = NSTextAlignment.Left
            timestampLabel.font = UIFont(name: "AppleSDGothicNeo-Regular", size: 12)
            timestampLabel.textColor = UIColor.darkGrayColor()
            timestampLabel.numberOfLines = 1
            
            retweetCount.numberOfLines = 1
            retweetCount.sizeToFit()
            retweetCount.font = UIFont(name: "AppleSDGothicNeo-Regular", size: CGFloat(10))
            retweetCount.textColor = UIColor.darkGrayColor()
            
            favoriteCount.numberOfLines = 1
            favoriteCount.sizeToFit()
            favoriteCount.font = UIFont(name: "AppleSDGothicNeo-Regular", size: CGFloat(10))
            favoriteCount.textColor = UIColor.darkGrayColor()
            
            if user?.username == User.currentUser?.username {
                deleteButton.hidden = false
            }
            
        } else {
            NSLog("UNEXPECTED: tweet is nil in ShowTweetViewController")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onReplyButtonClicked(sender: AnyObject) {
        replyButton.selected = true
        performSegueWithIdentifier("replyToTweetSegue", sender: self)
    }
    
    
    @IBAction func onRetweetButtonClicked(sender: AnyObject) {
        if retweetButton.selected == false {
            if let id = tweetId as Int? {
                // retweet
                TwitterClient.sharedInstance.retweet(id, completion: { (result, error) -> () in
                    if error != nil {
                        NSLog("ERROR: TwitterClient.sharedInstance.retweet: \(error)")
                    } else {
//                        NSLog("Successfully retweeted with result: \(result)")
                        self.retweetButton.selected = true
                        
                        let currentRetweetCount: Int = self.retweetCount.text!.toInt() as Int!
                        let updatedRetweetCount = (currentRetweetCount + 1) as Int
                        self.retweetCount.text = String(updatedRetweetCount)
                        
                        if let result = result as NSDictionary! {
                            if let id = result["id"] as! Int? {
                                self.retweetId = id
                            }
                        }
                    }
                })
            } else {
                NSLog("UNEXPECTED: tweet id is nil in onRetweetButtonClicked")
            }
        } else {
            if let retweetId = retweetId as Int? {
                // unretweet
                TwitterClient.sharedInstance.destroy(retweetId, completion: { (result, error) -> () in
                    if error != nil {
                        NSLog("ERROR: TwitterClient.sharedInstance.destroy: \(error)")
                    } else {
//                        NSLog("Successfully destroyed tweet with result: \(result)")
                        self.retweetButton.selected = false
                        
                        let currentRetweetCount: Int = self.retweetCount.text!.toInt() as Int!
                        let updatedRetweetCount = (currentRetweetCount - 1) as Int
                        self.retweetCount.text = String(updatedRetweetCount)
                    }
                })
            }
        }
    }
    
    
    @IBAction func onFavoriteButtonClicked(sender: AnyObject) {
        if favoriteButton.selected == false {
            if let id = tweetId as Int? {
                // add tweet as favorite
                TwitterClient.sharedInstance.createFavorite(id, completion: { (result, error) -> () in
                    if error != nil {
                        NSLog("ERROR: TwitterClient.sharedInstance.createFavorite: \(error)")
                    } else {
                        NSLog("Successfully created favorite.")
                        self.favoriteButton.selected = true
                        
                        let currentFavoriteCount: Int = self.favoriteCount.text!.toInt() as Int!
                        let updatedFavoriteCount = (currentFavoriteCount + 1) as Int
                        self.favoriteCount.text = String(updatedFavoriteCount)
                    }
                })
            } else {
                NSLog("UNEXPECTED: id is nil in onFavoriteButtonClicked")
            }
        } else {
            if let id = tweetId as Int? {
                // remove tweet as favorite
                TwitterClient.sharedInstance.destroyFavorite(id, completion: { (result, error) -> () in
                    if error != nil {
                        NSLog("ERROR: TwitterClient.sharedInstance.destroyFavorite: \(error)")
                    } else {
                        NSLog("Successfully destroyed/removed favorite.")
                        self.favoriteButton.selected = false
                        
                        let currentFavoriteCount: Int = self.favoriteCount.text!.toInt() as Int!
                        let updatedFavoriteCount = (currentFavoriteCount - 1) as Int
                        self.favoriteCount.text = String(updatedFavoriteCount)
                    }
                })
            } else {
                NSLog("UNEXPECTED: id is nil in onFavoriteButtonClicked")
            }
        }
        
    }
    
    @IBAction func deleteButtonClicked(sender: AnyObject) {
        TwitterClient.sharedInstance.destroy(tweetId!, completion: { (result, error) -> () in
            if error != nil {
                NSLog("ERROR: TwitterClient.sharedInstance.destroy: \(error)")
            } else {
                NSLog("Successfully destroyed/removed tweet.")
                self.performSegueWithIdentifier("afterDeleteTweetSegue", sender: self)
            }
        })
    }

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "replyToTweetSegue" {
            let composeTweetViewController = segue.destinationViewController as! ComposeTweetViewController
            composeTweetViewController.replyToTweetId = tweetId
            composeTweetViewController.tweetTextPrefix = screennameLabel.text
            composeTweetViewController.user = User.currentUser!
        }
    }
}
