//
//  TweetTableViewCell.swift
//  Warble
//
//  Created by Monica Sun on 5/21/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

@objc protocol TweetTableViewCellDelegate {
    optional func tweetTableViewCell(tweetTableViewCell: TweetTableViewCell, replyButtonClicked value: Bool)
    
    optional func tweetTableViewCell(tweetTableViewCell: TweetTableViewCell, deleteButtonClicked value: Bool)
}

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var screename: UILabel!
    
    @IBOutlet weak var tweetText: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var favoriteCount: UILabel!
    
    var imageUrlString = String()
    var retweetId: Int?
    
    weak var delegate: TweetTableViewCellDelegate?
    
    var tweet: Tweet! {
        didSet {
            name.text = tweet.user?.name
            imageUrlString = tweet.user?.profileImageUrl as String!
            profileImage.setImageWithURL(NSURL(string: imageUrlString))
            profileImage.layer.cornerRadius = 5
//            profileImage.clipsToBounds = true
            profileImage.frame.size.width = 40
            profileImage.frame.size.height = 40
            profileImage.contentMode = UIViewContentMode.ScaleAspectFill
            
            screename.text = "@" + (tweet.user?.username as String!)
            tweetText.text = tweet.text
//            timestamp.text = tweet.createdAtString
            timestamp.text = tweet.createdAt!.shortTimeAgoSinceNow()
            
            retweetCount.text = String(tweet.retweetCount as Int!)
            favoriteCount.text = String(tweet.favoriteCount as Int!)
            
            if tweet.user?.username == User.currentUser?.username {
                deleteButton.hidden = false
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        name.preferredMaxLayoutWidth = name.frame.size.width
        name.numberOfLines = 1
        screename.numberOfLines = 1
        name.font = UIFont(name: "AppleSDGothicNeo-Regular", size: CGFloat(12))
        screename.font = UIFont(name: "AppleSDGothicNeo-Regular", size: CGFloat(10))
        
        tweetText.numberOfLines = 0
        tweetText.font = UIFont(name: "AppleSDGothicNeo-Regular", size: CGFloat(12))
        timestamp.numberOfLines = 1
        timestamp.font = UIFont(name: "AppleSDGothicNeo-Regular", size: CGFloat(10))
        
        retweetCount.numberOfLines = 1
        retweetCount.sizeToFit()
        retweetCount.font = UIFont(name: "AppleSDGothicNeo-Regular", size: CGFloat(10))
        retweetCount.textColor = UIColor.darkGrayColor()
        
        favoriteCount.numberOfLines = 1
        favoriteCount.sizeToFit()
        favoriteCount.font = UIFont(name: "AppleSDGothicNeo-Regular", size: CGFloat(10))
        favoriteCount.textColor = UIColor.darkGrayColor()
        
        
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
        
        replyButton.addTarget(self, action: "replyButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
        
        // hide delete button by default
        deleteButton.hidden = true
        deleteButton.selected = false
        deleteButton.setImage(UIImage(named: "trash"), forState: UIControlState.Normal)
        
        deleteButton.addTarget(self, action: "deleteButtonClicked", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        name.preferredMaxLayoutWidth = name.frame.size.width
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    @IBAction func onRetweetButtonClicked(sender: AnyObject) {
        if retweetButton.selected == false {
            if let id = tweet.tweetId as Int? {
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
                        NSLog("Successfully destroyed tweet.")
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
            if let id = tweet.tweetId as Int? {
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
            if let id = tweet.tweetId as Int? {
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
    
    func replyButtonClicked() {
//        if replyButton.selected {
//            replyButton.selected = false
//        } else {
//            replyButton.selected = true
//        }
        
        replyButton.selected = true
        
        NSLog("replyButtonClicked")
        delegate?.tweetTableViewCell?(self, replyButtonClicked: replyButton.selected)
    }
    
    func deleteButtonClicked() {
        deleteButton.selected = true
        NSLog("deleteButtonClicked. Deleting tweet...")
        
        delegate?.tweetTableViewCell?(self, deleteButtonClicked: deleteButton.selected)
    }

}
