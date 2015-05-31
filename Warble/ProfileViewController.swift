//
//  ProfileViewController.swift
//  Warble
//
//  Created by Monica Sun on 5/29/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit
import Social

class ProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TweetTableViewCellDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    // outlets
    @IBOutlet weak var userTimelineTableView: UITableView!
    @IBOutlet weak var profilePageControl: UIPageControl!
//    @IBOutlet weak var profileInfoTextView: UITextView!
    @IBOutlet weak var profileBannerImageView: UIImageView!
    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var taglineLabel: UILabel!
    
    @IBOutlet weak var topBannerImageView: UIImageView!
        
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    @IBOutlet weak var numTweetsLabel: UILabel!
    @IBOutlet weak var numFollowingLabel: UILabel!
    @IBOutlet weak var numFollowersTweet: UILabel!
    
    @IBOutlet weak var TWEETS_Label: UILabel!
    @IBOutlet weak var FOLLOWING_label: UILabel!
    @IBOutlet weak var FOLLOWERS_label: UILabel!
    
    
    // user info
    var name: String?
    var username: String?
    var profileImageUrl: String?
    var tagline: String?
    
    var bannerImageUrlString: String?
    var numTweets: Int?
    var numFollowing: Int?
    var numFollowers: Int?
    
    var userTweets = [Tweet]()
    var minId: Int?
    
    var profilePageControlSelectedIndex = 0
    
    var currentlySelectedTweet: Tweet?
    var originalTopBannerImageViewBounds: CGRect?
    var originalTopBannerImageViewCenter: CGPoint?
    var originalTopBannerImageViewOrigin: CGPoint?
    
    @IBOutlet weak var bar: UIView!
    
    
    var user: User! {
        didSet {
            name = user!.name
            profileImageUrl = user!.profileImageUrl as String!
            username = user!.username as String!
            tagline = user.tagline as String!
            numTweets = user!.dict["statuses_count"] as? Int
            numFollowing = user!.dict["friends_count"] as? Int
            numFollowers = user!.dict["followers_count"] as? Int

            TwitterClient.sharedInstance.userTimelineWithParams(username!, maxId: nil, completion: { (userTweets, minId, error) -> () in
                if error != nil {
                    NSLog("ERROR: TwitterClient.sharedInstance.userTimelineWithParams: \(error)")
                } else {
                    self.userTweets = userTweets!
                    self.minId = minId
                    self.userTimelineTableView.reloadData()
                }
            })

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        userTimelineTableView.dataSource = self
        userTimelineTableView.delegate = self
        userTimelineTableView.rowHeight = UITableViewAutomaticDimension
        userTimelineTableView.estimatedRowHeight = 200
        
        nameLabel.text = name
        
        profileImageView.setImageWithURL(NSURL(string: profileImageUrl!))
        profileImageView.layer.cornerRadius = 5
        //            profileImage.clipsToBounds = true
        profileImageView.frame.size.width = 80
        profileImageView.frame.size.height = 80
        profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        usernameLabel.text = "@" + username!
        
        taglineLabel.text = user!.tagline!
        
        locationLabel.text = user!.dict["location"] as? String
        
        originalTopBannerImageViewBounds = topBannerImageView.bounds
        originalTopBannerImageViewCenter = topBannerImageView.center
        originalTopBannerImageViewOrigin = topBannerImageView.frame.origin
        
        TwitterClient.sharedInstance.profileBannerForUser(username!, completion: { (url, error) -> () in
            if error != nil {
                NSLog("ERROR: TwitterClient.sharedInstance.profileBannerForUser: \(error)")
            } else {
                self.bannerImageUrlString = url
                self.topBannerImageView.setImageWithURL(NSURL(string: self.bannerImageUrlString!))
                self.profileBannerImageView.setImageWithURL(NSURL(string: self.bannerImageUrlString!))
            }
        })
        
//        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
//        blurEffectView.frame = topBannerImageView.bounds
//        topBannerImageView.addSubview(blurEffectView)
        
        numTweetsLabel.text = String(numTweets as Int!)
        numFollowingLabel.text = String(numFollowing as Int!)
        numFollowersTweet.text = String(numFollowers as Int!)
        
        // stying
        taglineLabel.textAlignment = .Left
        taglineLabel.hidden = true
        
        nameLabel.textAlignment = NSTextAlignment.Left
        nameLabel.font = UIFont(name: "HelveticaNeue", size: 24)
        nameLabel.numberOfLines = 1
        
        usernameLabel.textAlignment = NSTextAlignment.Left
        usernameLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        usernameLabel.textColor = UIColor.darkGrayColor()
        usernameLabel.numberOfLines = 1
        
        locationLabel.textAlignment = NSTextAlignment.Left
        locationLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        locationLabel.textColor = UIColor.darkGrayColor()
        locationLabel.numberOfLines = 1
        
        topBannerImageView.layer.borderWidth = 4
        topBannerImageView.layer.borderColor = bar.backgroundColor?.CGColor!
        
        taglineLabel.font = UIFont(name: "HelveticaNeue", size: 14)
        taglineLabel.textColor = UIColor.darkGrayColor()
        taglineLabel.clipsToBounds = true
        
        numTweetsLabel.textAlignment = NSTextAlignment.Left
        numTweetsLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        numTweetsLabel.textColor = UIColor.darkGrayColor()
        numTweetsLabel.numberOfLines = 1
        
        numFollowingLabel.textAlignment = NSTextAlignment.Left
        numFollowingLabel.font = UIFont(name: "HelveticaNeue", size: 12)
        numFollowingLabel.textColor = UIColor.darkGrayColor()
        numFollowingLabel.numberOfLines = 1
        
        numFollowersTweet.textAlignment = NSTextAlignment.Left
        numFollowersTweet.font = UIFont(name: "HelveticaNeue", size: 12)
        numFollowersTweet.textColor = UIColor.darkGrayColor()
        numFollowersTweet.numberOfLines = 1
        
        TWEETS_Label.textAlignment = NSTextAlignment.Left
        TWEETS_Label.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        TWEETS_Label.textColor = UIColor.darkGrayColor()
        TWEETS_Label.numberOfLines = 1
        
        FOLLOWING_label.textAlignment = NSTextAlignment.Left
        FOLLOWING_label.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        FOLLOWING_label.textColor = UIColor.darkGrayColor()
        FOLLOWING_label.numberOfLines = 1
        
        FOLLOWERS_label.textAlignment = NSTextAlignment.Left
        FOLLOWERS_label.font = UIFont(name: "HelveticaNeue-Bold", size: 12)
        FOLLOWERS_label.textColor = UIColor.darkGrayColor()
        FOLLOWERS_label.numberOfLines = 1
        
        topBannerImageView.contentMode = UIViewContentMode.ScaleAspectFill
        profileBannerImageView.contentMode = UIViewContentMode.ScaleAspectFill
        
        // header image pan gesture
        var panRecognizer = UIPanGestureRecognizer(target:self, action:"respondToPanGesture:")
        topBannerImageView.userInteractionEnabled = true
        topBannerImageView.addGestureRecognizer(panRecognizer)
        
        
        // pageControl swipe gestures
        profilePageControlSelectedIndex = profilePageControl.currentPage
        profilePageControl.addTarget(self, action: "profileControlValueChanged", forControlEvents: UIControlEvents.ValueChanged)
        
        var swipeRight = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        swipeRight.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(swipeRight)
        
        var swipeLeft = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeLeft.direction = UISwipeGestureRecognizerDirection.Left
        swipeLeft.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(swipeLeft)
        
//        tweetTextLabel.textAlignment = NSTextAlignment.Left
//        tweetTextLabel.font = UIFont(name: "HelveticaNeue", size: 14)
//        tweetTextLabel.numberOfLines = 0
//        
//        timestampLabel.textAlignment = NSTextAlignment.Left
//        timestampLabel.font = UIFont(name: "HelveticaNeue", size: 12)
//        timestampLabel.textColor = UIColor.darkGrayColor()
//        timestampLabel.numberOfLines = 1
//        
//        retweetCount.numberOfLines = 1
//        retweetCount.sizeToFit()
//        retweetCount.font = UIFont(name: "HelveticaNeue", size: CGFloat(10))
//        retweetCount.textColor = UIColor.darkGrayColor()
//        
//        favoriteCount.numberOfLines = 1
//        favoriteCount.sizeToFit()
//        favoriteCount.font = UIFont(name: "HelveticaNeue", size: CGFloat(10))
//        favoriteCount.textColor = UIColor.darkGrayColor()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userTweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = TweetTableViewCell()
        
        if userTweets.count > indexPath.row {
            cell = tableView.dequeueReusableCellWithIdentifier("tweetCell", forIndexPath: indexPath) as! TweetTableViewCell
            cell.tweet = userTweets[indexPath.row]
            cell.delegate = self
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if userTweets.count > indexPath.row {
            currentlySelectedTweet = userTweets[indexPath.row]
            performSegueWithIdentifier("showTweetSegueFromUserTimeline", sender: self)
        } else {
            NSLog("ERROR: In didSelectRowAtIndexPath, userTweets.count: \(userTweets.count) is less than or equal to indexPath.row: \(indexPath.row). Cannot segue to show tweet from User Timeline.")
        }
    }

    func profileControlValueChanged(sender: AnyObject) {
        
        UIView.animateWithDuration(0.7, animations: {
            if self.profileBannerImageView.alpha < 0.2 {
                self.profileBannerImageView.alpha = 0.25
            } else if self.profileBannerImageView.alpha < 0.3 {
                self.profileBannerImageView.alpha = 0.35
            } else {
                self.profileBannerImageView.alpha = 0.12
            }
        })
        
        
        NSLog("page control changed!")
        let selectedPage = profilePageControl.currentPage
        switch selectedPage {
        case 0:
            nameLabel.hidden = false
            usernameLabel.hidden = false
            locationLabel.hidden = false
            
            taglineLabel.hidden = true
            numTweetsLabel.hidden = true
            numFollowingLabel.hidden = true
            numFollowersTweet.hidden = true
            TWEETS_Label.hidden = true
            FOLLOWERS_label.hidden = true
            FOLLOWING_label.hidden = true
            
//            nameLabel.text = name
//            usernameLabel.text = "@" + username!
//            locationLabel.text = user!.dict["location"] as? String
//            
//            nameLabel.textAlignment = NSTextAlignment.Left
//            nameLabel.font = UIFont(name: "HelveticaNeue", size: 24)
//            nameLabel.numberOfLines = 1
//            
//            usernameLabel.textAlignment = NSTextAlignment.Left
//            usernameLabel.font = UIFont(name: "HelveticaNeue", size: 16)
//            usernameLabel.textColor = UIColor.darkGrayColor()
//            usernameLabel.numberOfLines = 1
//            
//            locationLabel.textAlignment = NSTextAlignment.Left
//            locationLabel.font = UIFont(name: "HelveticaNeue", size: 12)
//            locationLabel.textColor = UIColor.darkGrayColor()
//            locationLabel.numberOfLines = 1
        case 1:
            taglineLabel.hidden = false
            
            nameLabel.hidden = true
            usernameLabel.hidden = true
            locationLabel.hidden = true
            numTweetsLabel.hidden = true
            numFollowingLabel.hidden = true
            numFollowersTweet.hidden = true
            TWEETS_Label.hidden = true
            FOLLOWERS_label.hidden = true
            FOLLOWING_label.hidden = true
        case 2:
            taglineLabel.hidden = true
            nameLabel.hidden = true
            usernameLabel.hidden = true
            locationLabel.hidden = true
            
            numTweetsLabel.hidden = false
            numFollowingLabel.hidden = false
            numFollowersTweet.hidden = false
            TWEETS_Label.hidden = false
            FOLLOWERS_label.hidden = false
            FOLLOWING_label.hidden = false
            
        default:
            NSLog("UNEXPECTED: selected page control index: \(selectedPage)")
        }
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Right:
                NSLog("swipe right gesture!")
                profilePageControlSelectedIndex++
            case UISwipeGestureRecognizerDirection.Left:
                NSLog("swipe left gesture!")
                profilePageControlSelectedIndex--
            default:
                NSLog("ERROR: Unexpected swipe gesture direction: \(swipeGesture.direction)")
                break
            }
            
            if profilePageControlSelectedIndex < 0 {
                profilePageControlSelectedIndex = 0
            }
            
            if profilePageControlSelectedIndex >= profilePageControl.numberOfPages {
                profilePageControlSelectedIndex = profilePageControl.numberOfPages - 1
            }
        
            profilePageControl.currentPage = profilePageControlSelectedIndex
            profileControlValueChanged(profilePageControl)
        }
    }
    
    func respondToPanGesture(panGestureRecognizer: UIPanGestureRecognizer) {
        var startingPoint = panGestureRecognizer.locationInView(topBannerImageView) // point of pan gesture
        var velocity = panGestureRecognizer.velocityInView(topBannerImageView)
        
        
//        self.center = CGPointMake(lastLocation.x + translation.x, lastLocation.y + translation.y)
        
        if panGestureRecognizer.state == UIGestureRecognizerState.Began {
            println("Pan Gesture began at: \(startingPoint)")
            startingPoint = panGestureRecognizer.locationInView(topBannerImageView)
            
        } else if panGestureRecognizer.state == UIGestureRecognizerState.Changed {
            println("Pan Gesture changed at: \(panGestureRecognizer.locationInView(topBannerImageView))")
            
            var translation = panGestureRecognizer.translationInView(topBannerImageView)
            // debug
            println("translation x: \(translation.x)")
            println("translation y: \(translation.y)")
            
//            self.topBannerImageView.center.y += translation.y/3
//            self.topBannerImageView.frame.size.height += translation.y
            
            UIView.animateWithDuration(1.5, animations: {
//                self.topBannerImageView.center.y += translation.y
                self.topBannerImageView.frame.size.height += translation.y
            })
            
//            let scale = translation.y/startingPoint.y
//            
//            let size = CGSizeApplyAffineTransform(topBannerImageView.bounds.size, CGAffineTransformMakeScale(scale, scale))
//            
//            UIGraphicsBeginImageContextWithOptions(size, true, scale)
//            topBannerImageView.image!.drawInRect(CGRect(origin: CGPointZero, size: size))
//            
//            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
//            UIGraphicsEndImageContext()
            
        } else if panGestureRecognizer.state == UIGestureRecognizerState.Ended {
            println("Pan Gesture ended at: \(panGestureRecognizer.locationInView(topBannerImageView))")
            UIView.animateWithDuration(1.5, animations: {
                self.topBannerImageView.center = self.originalTopBannerImageViewCenter!
                self.topBannerImageView.bounds = self.originalTopBannerImageViewBounds!
                self.topBannerImageView.frame.origin = self.originalTopBannerImageViewOrigin!
            })
        }
    }
    
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showTweetSegueFromUserTimeline" {
            let showTweetViewController = segue.destinationViewController as! ShowTweetViewController
            showTweetViewController.tweet = currentlySelectedTweet
        }
        
        if segue.identifier == "replyToTweetFromUserTimelineSegue" {
            let composeViewController = segue.destinationViewController as! ComposeTweetViewController
            composeViewController.user = user
            composeViewController.replyToTweetId = currentlySelectedTweet?.tweetId
            composeViewController.tweetTextPrefix = "@" + (currentlySelectedTweet?.user?.username as String!)
        }
    }
    
    // delegate functions
    func tweetTableViewCell(tweetTableViewCell: TweetTableViewCell, replyButtonClicked value: Bool) {
        NSLog("replyButtonClicked event")
        currentlySelectedTweet = tweetTableViewCell.tweet
        performSegueWithIdentifier("replyToTweetFromUserTimelineSegue", sender: self)
    }
    
    func tweetTableViewCell(tweetTableViewCell: TweetTableViewCell, deleteButtonClicked value: Bool) {
        NSLog("deleteButtonClicked event")
        currentlySelectedTweet = tweetTableViewCell.tweet
        let indexPathCellToDelete = userTimelineTableView.indexPathForCell(tweetTableViewCell)
        
        TwitterClient.sharedInstance.destroy(currentlySelectedTweet!.tweetId!, completion: { (result, error) -> () in
            if error != nil {
                NSLog("ERROR: TwitterClient.sharedInstance.destroy: \(error)")
            } else {
                NSLog("Successfully destroyed/removed tweet from User Timeline.")
                
                if self.userTweets.count > indexPathCellToDelete!.row {
                    self.userTweets.removeAtIndex(indexPathCellToDelete!.row)
                } else {
                    NSLog("UNEXPECTED: self.userTweets.count is less than/equal to indexPathCellToDelete.row. Cannot delete tweet from User Timeline!")
                }
                
                self.userTimelineTableView.beginUpdates()
                self.userTimelineTableView.deleteRowsAtIndexPaths([indexPathCellToDelete!], withRowAnimation: UITableViewRowAnimation.Fade)
                self.userTimelineTableView.endUpdates()
            }
        })
    }
    
    func tweetTableViewCell(tweetTableViewCell: TweetTableViewCell, fbShareButtonClicked value: Bool) {
        NSLog("fbShareButtonClicked event")
        
        var referenceText = String()
        if let authorUsername = tweetTableViewCell.tweet?.user?.username as String? {
            if let tweetText = tweetTableViewCell.tweet?.text as String? {
                referenceText = "@\(authorUsername): \(tweetText)"
            }
        }
        
        if !referenceText.isEmpty {
            if SLComposeViewController.isAvailableForServiceType(SLServiceTypeFacebook) {
                var fbSharePost: SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                fbSharePost.setInitialText(referenceText)
                if let mediaUrl = tweetTableViewCell.tweet?.mediaUrl {
                    var success = fbSharePost.addURL(NSURL(string: mediaUrl))
                    if !success {
                        NSLog("ERROR: Could not add image URL to fb post")
                    }
                }
                self.presentViewController(fbSharePost, animated: true, completion: nil)
            } else {
                var alert = UIAlertController(title: "Sign Into Facebook", message: "Sign into your facebook account to share.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Got it.", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }


}
