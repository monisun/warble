//
//  TweetsViewController.swift
//  Warble
//
//  Created by Monica Sun on 5/21/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit
import Social

@objc protocol TweetsViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func collapseSidePanels()
}

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TweetTableViewCellDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    var delegate: TweetsViewControllerDelegate?
    
    let pageIndexOffset = 199  // max allowed per Twitter API is 200
    var minId: Int?             // min tweet id of currently fetched tweets
    var mentionsMinId: Int?
    let maxNumTweetsToKeepInMemory = 1000
    
    var tweets = [Tweet]()
    var homeTweets = [Tweet]()
    var mentionsTweets = [Tweet]()
    
    var refreshControl = UIRefreshControl()
    var currentlySelectedTweet: Tweet?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchActive = false
    var lastSearchedTerm = String()
    var searchResultTweets = [Tweet]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationItem.titleView = searchBar
        searchBar.delegate = self
        searchBar.translucent = true
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        // initial request for landing page
        SVProgressHUD.showProgress(1, status: "Loading...")
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, maxId: nil, completion: { (tweets, minId, error) -> () in
            if error != nil {
                SVProgressHUD.dismiss()
                NSLog("ERROR: TwitterClient.sharedInstance.homeTimelineWithParams: \(error)")
            } else {
                self.homeTweets = self.tweets
                self.tweets = tweets!
                self.tableView.reloadData()
                self.minId = minId
                SVProgressHUD.showSuccessWithStatus("Success")
            }
        })
    
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
//        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        if tweets.count > maxNumTweetsToKeepInMemory {
            tweets.removeRange(Range(start: 0, end: maxNumTweetsToKeepInMemory))
        }
    }
    
    
//    @IBAction func onLogout(sender: AnyObject) {
//        User.currentUser?.logout()
//    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false
        tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = true
        let searchTerms = searchBar.text
        lastSearchedTerm = searchTerms
        
        TwitterClient.sharedInstance.searchTweets(searchTerms, completion: { (tweets, minId, error) -> () in
            if error != nil {
                SVProgressHUD.dismiss()
                NSLog("ERROR: Searching tweets with TwitterClient.sharedInstance.searchTweets: \(error)")
            } else {
                self.searchResultTweets = tweets!
                self.tableView.reloadData()
                SVProgressHUD.showSuccessWithStatus("Success")
            }
        })
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchActive {
            return searchResultTweets.count
        } else {
            return tweets.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = TweetTableViewCell()
        
        if searchActive {
            if searchResultTweets.count > indexPath.row {
                cell = tableView.dequeueReusableCellWithIdentifier("tweetCell", forIndexPath: indexPath) as! TweetTableViewCell
                cell.tweet = searchResultTweets[indexPath.row]
                cell.delegate = self
            } else {
                NSLog("ERROR: searchResultTweets[] does not contain index: \(indexPath.row)")
            }
            
        } else {
            if tweets.count > indexPath.row {
                cell = tableView.dequeueReusableCellWithIdentifier("tweetCell", forIndexPath: indexPath) as! TweetTableViewCell
                cell.tweet = tweets[indexPath.row]
                cell.delegate = self
            } else {
                NSLog("ERROR: tweets[] does not contain index: \(indexPath.row)")
            }
            
            if (indexPath.row == tweets.count - 1 && tweets.count >= 100) || ((indexPath.row > 0) && (indexPath.row % pageIndexOffset == 0)) {
                
                // fetch more results
                let maxIdForRequest = minId! - 1
                SVProgressHUD.showProgress(1, status: "Loading...")
                
                TwitterClient.sharedInstance.homeTimelineWithParams(nil, maxId: maxIdForRequest, completion:  { (tweets, minId, error) -> () in
                    if error != nil {
                        SVProgressHUD.dismiss()
                        NSLog("ERROR: Fetching more results with TwitterClient.sharedInstance.homeTimelineWithParams: \(error)")
                    } else {
                        // extend for scrolling
                        self.tweets.extend(tweets!)
                        self.tableView.reloadData()
                        self.minId = minId
                        SVProgressHUD.showSuccessWithStatus("Success")
                    }
                })
            }
        }
        
        if let tweetForCell = cell.tweet as Tweet! {
            if let mediaUrl = tweetForCell.mediaUrl as String? {
                cell.mediaImageView.hidden = false
            }
        }
 
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if searchActive {
            if searchResultTweets.count > indexPath.row {
                currentlySelectedTweet = searchResultTweets[indexPath.row]
                performSegueWithIdentifier("showTweetSegue", sender: self)
            } else {
                NSLog("ERROR: In didSelectRowAtIndexPath, searchResultTweets.count: \(searchResultTweets.count) is less than or equal to indexPath.row: \(indexPath.row). Cannot segue to show tweet.")
            }
        } else {
            if tweets.count > indexPath.row {
                currentlySelectedTweet = tweets[indexPath.row]
                performSegueWithIdentifier("showTweetSegue", sender: self)
            } else {
                NSLog("ERROR: In didSelectRowAtIndexPath, tweets.count: \(tweets.count) is less than or equal to indexPath.row: \(indexPath.row). Cannot segue to show tweet.")
            }
        }

    }
    
    func onRefresh() {
        SVProgressHUD.showProgress(1, status: "Loading...")
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, maxId: nil, completion: { (tweets, minId, error) -> () in
            if error != nil {
                SVProgressHUD.dismiss()
                NSLog("ERROR: onRefresh TwitterClient.sharedInstance.homeTimelineWithParams: \(error)")
            } else {
                // set searchActive to false for pull to refresh (always refresh home timeline)
                self.searchActive = false
                
                self.tweets = tweets!
                self.tableView.reloadData()
                self.minId = minId
                self.refreshControl.endRefreshing()
                SVProgressHUD.showSuccessWithStatus("Success")
            }
        })
    }
    
    
    @IBAction func composeButtonClicked(sender: AnyObject) {
        performSegueWithIdentifier("composeSegue", sender: self)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "composeSegue" {
            let composeViewController = segue.destinationViewController as! ComposeTweetViewController
            composeViewController.user = User.currentUser!
        }
        
        if segue.identifier == "showTweetSegue" {
            let showTweetViewController = segue.destinationViewController as! ShowTweetViewController
            showTweetViewController.tweet = currentlySelectedTweet
        }
        
        if segue.identifier == "replyToTweetFromHomeTimelineSegue" {
            let composeViewController = segue.destinationViewController as! ComposeTweetViewController
            composeViewController.user = User.currentUser!
            composeViewController.replyToTweetId = currentlySelectedTweet?.tweetId
            composeViewController.tweetTextPrefix = "@" + (currentlySelectedTweet?.user?.username as String!)
        }
        
        if segue.identifier == "showUserSegue" {
            let profileViewController = segue.destinationViewController as! ProfileViewController
            profileViewController.user = currentlySelectedTweet?.user
        }
        
        if segue.identifier == "menuShowUserProfile" {
            let profileViewController = segue.destinationViewController as! ProfileViewController
            profileViewController.user = User.currentUser
        }
        
        if segue.identifier == "showContainerVC" {
            let containerVC = segue.destinationViewController as! ContainerViewController
            containerVC.toggleLeftPanelImmediately = true            
        }
    }

    // delegate functions
    func tweetTableViewCell(tweetTableViewCell: TweetTableViewCell, replyButtonClicked value: Bool) {
        NSLog("replyButtonClicked event")
        currentlySelectedTweet = tweetTableViewCell.tweet
        performSegueWithIdentifier("replyToTweetFromHomeTimelineSegue", sender: self)
    }
    
    func tweetTableViewCell(tweetTableViewCell: TweetTableViewCell, deleteButtonClicked value: Bool) {
        NSLog("deleteButtonClicked event")
        currentlySelectedTweet = tweetTableViewCell.tweet
        let indexPathCellToDelete = tableView.indexPathForCell(tweetTableViewCell)
        
        TwitterClient.sharedInstance.destroy(currentlySelectedTweet!.tweetId!, completion: { (result, error) -> () in
            if error != nil {
                NSLog("ERROR: TwitterClient.sharedInstance.destroy: \(error)")
            } else {
                NSLog("Successfully destroyed/removed tweet.")
                
                if self.tweets.count > indexPathCellToDelete!.row {
                    self.tweets.removeAtIndex(indexPathCellToDelete!.row)
                } else {
                    NSLog("UNEXPECTED: self.tweets.count is less than/equal to indexPathCellToDelete.row. Cannot delete tweet!")
                }
                
                self.tableView.beginUpdates()
                self.tableView.deleteRowsAtIndexPaths([indexPathCellToDelete!], withRowAnimation: UITableViewRowAnimation.Fade)
                self.tableView.endUpdates()
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
    
    func tweetTableViewCell(tweetTableViewCell: TweetTableViewCell, profileImageClicked username: String) {
        NSLog("profileImageClicked event")
        currentlySelectedTweet = tweetTableViewCell.tweet
        performSegueWithIdentifier("showUserSegue", sender: self)
    }
    
    @IBAction func menuButtonClicked(sender: AnyObject) {
        performSegueWithIdentifier("showContainerVC", sender: self)
        
//        let mainStoryBoard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//        let containerViewController = mainStoryBoard.instantiateViewControllerWithIdentifier("ContainerViewController") as? ContainerViewController
//        addChildViewController(containerViewController!)
//        containerViewController!.didMoveToParentViewController(self)
//        
//        containerViewController!.toggleLeftPanel()
    }
    
}

extension TweetsViewController: SidePanelViewControllerDelegate {
    func menuItemSelected(selectedMenuItem: String) {
        switch selectedMenuItem {
        case "profile":
            NSLog("hamburger menu: show user profile!")
            performSegueWithIdentifier("menuShowUserProfile", sender: self)
            
        case "home":
            NSLog("hamburger menu: show home timeline!")
            
            TwitterClient.sharedInstance.homeTimelineWithParams(nil, maxId: nil, completion: { (tweets, minId, error) -> () in
                if error != nil {
                    NSLog("ERROR: TwitterClient.sharedInstance.homeTimelineWithParams: \(error)")
                } else {
                    self.homeTweets = tweets!
                    self.tweets = self.homeTweets
                    self.minId = minId
                }
            })
            
        case "mentions":
            NSLog("hamburger menu: show mentions page!")
            
            TwitterClient.sharedInstance.mentionsTimeline(nil, completion: { (mentions, minId, error) -> () in
                if error != nil {
                    NSLog("ERROR: TwitterClient.sharedInstance.mentionsTimeline: \(error)")
                } else {
                    self.mentionsTweets = mentions!
                    self.tweets = self.mentionsTweets
                    self.mentionsMinId = minId
                }
            })
        case "logout":
            User.currentUser?.logout()
            
        default:
            NSLog("UNEXPECTED: hamburger menu selected item: \(selectedMenuItem)")
        }
        delegate?.collapseSidePanels?()
    }
}




