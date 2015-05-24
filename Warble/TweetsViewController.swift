//
//  TweetsViewController.swift
//  Warble
//
//  Created by Monica Sun on 5/21/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TweetTableViewCellDelegate, UISearchBarDelegate, UISearchDisplayDelegate {
    let pageIndexOffset = 199  // max allowed per Twitter API is 200
    var minId: Int?             // min tweet id of currently fetched tweets
    let maxNumTweetsToKeepInMemory = 1000
    
    var tweets = [Tweet]()
    var refreshControl = UIRefreshControl()
    var currentlySelectedTweet: Tweet?
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchActive = false
    var lastSearchedTerm = String()
    var searchResultTweets = [Tweet]()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = searchBar
        searchBar.delegate = self
        //        searchBar.showsCancelButton = true
        searchBar.translucent = true
        
//        self.tableView.backgroundColor = UIColor(red: CGFloat(194/255), green: CGFloat(1), blue: CGFloat(1), alpha: CGFloat(0.02))
        
//        let logoTitleImage = UIImage(named: "logo")
//        let logoTitleImageView = UIImageView(image: logoTitleImage)
//        logoTitleImageView.contentMode = UIViewContentMode.ScaleAspectFit
//        logoTitleImageView.frame.size.height = 20
//        logoTitleImageView.frame.size.width = 20
//        self.navigationItem.titleView = logoTitleImageView
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 80
        
        // initial request for landing page
        SVProgressHUD.showProgress(1, status: "Loading...")
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, maxId: nil, completion: { (tweets, minId, error) -> () in
            if error != nil {
                SVProgressHUD.dismiss()
                NSLog("ERROR: TwitterClient.sharedInstance.homeTimelineWithParams: \(error)")
            } else {
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
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        if tweets.count > maxNumTweetsToKeepInMemory {
            tweets.removeRange(Range(start: 0, end: maxNumTweetsToKeepInMemory))
        }
    }
    
    
    @IBAction func onLogout(sender: AnyObject) {
        User.currentUser?.logout()
    }
    
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
            
            if (indexPath.row == tweets.count - 1) || ((indexPath.row > 0) && (indexPath.row % pageIndexOffset == 0)) {
                
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
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tweets.count > indexPath.row {
            currentlySelectedTweet = tweets[indexPath.row]
            performSegueWithIdentifier("showTweetSegue", sender: self)
        } else {
            NSLog("ERROR: In didSelectRowAtIndexPath, tweets.count: \(tweets.count) is less than or equal to indexPath.row: \(indexPath.row). Cannot segue to show tweet.")
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
    }

    
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

}
