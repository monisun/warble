//
//  TweetsViewController.swift
//  Warble
//
//  Created by Monica Sun on 5/21/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, TweetTableViewCellDelegate {
    let pageIndexOffset = 199  // max allowed per Twitter API is 200
    var minId: Int?             // min tweet id of currently fetched tweets
    let maxNumTweetsToKeepInMemory = 1000
    
    var tweets = [Tweet]()
    var refreshControl = UIRefreshControl()
    var currentlySelectedTweet: Tweet?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, maxId: nil, completion: { (tweets, minId, error) -> () in
            if error != nil {
                NSLog("ERROR: TwitterClient.sharedInstance.homeTimelineWithParams: \(error)")
            } else {
                self.tweets = tweets!
                self.tableView.reloadData()
                self.minId = minId
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
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = TweetTableViewCell()
        
        if tweets.count > indexPath.row {
            cell = tableView.dequeueReusableCellWithIdentifier("tweetCell", forIndexPath: indexPath) as! TweetTableViewCell
            cell.tweet = tweets[indexPath.row]
            cell.delegate = self
        } else {
            NSLog("ERROR: tweets[] does not contain index: \(indexPath.row)")
        }
        
        println(indexPath.row)
        
        if (indexPath.row == tweets.count - 1) || ((indexPath.row > 0) && (indexPath.row % pageIndexOffset == 0)) {
            // debug
            println(indexPath.row)
            
            // fetch more results
            let maxIdForRequest = minId! - 1
            TwitterClient.sharedInstance.homeTimelineWithParams(nil, maxId: maxIdForRequest, completion:  { (tweets, minId, error) -> () in
                if error != nil {
                    NSLog("ERROR: Fetching more results with TwitterClient.sharedInstance.homeTimelineWithParams: \(error)")
                } else {
                    // extend for scrolling
                    self.tweets.extend(tweets!)
                    // debug
                    println (self.tweets.count)
                    self.tableView.reloadData()
                    self.minId = minId
                }
            })
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
        TwitterClient.sharedInstance.homeTimelineWithParams(nil, maxId: nil, completion: { (tweets, minId, error) -> () in
            if error != nil {
                NSLog("ERROR: onRefresh TwitterClient.sharedInstance.homeTimelineWithParams: \(error)")
            } else {
                self.tweets = tweets!
                self.tableView.reloadData()
                self.minId = minId
                self.refreshControl.endRefreshing()
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

}
