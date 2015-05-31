//
//  CenterViewController.swift
//  Warble
//
//  Created by Monica Sun on 5/31/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

@objc protocol CenterViewControllerDelegate {
    optional func toggleLeftPanel()
    optional func collapseSidePanels()
}

class CenterViewController: TweetsViewController {
    
    var delegate: CenterViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "menuShowUserProfile" {
            let profileViewController = segue.destinationViewController as! ProfileViewController
            profileViewController.user = User.currentUser
        }
    }

}

extension CenterViewController: SidePanelViewControllerDelegate {
    func menuItemSelected(selectedMenuItem: String) {
        switch selectedMenuItem {
        case "profile":
            NSLog("hamburger menu: show user profile!")
            performSegueWithIdentifier("menuShowUserProfile", sender: self)
        
        case "home":
            NSLog("hamburger menu: show home timeline!")
        
        case "mentions":
            NSLog("hamburger menu: show mentions page!")
            
            TwitterClient.sharedInstance.mentionsTimeline(nil, completion: { (mentions, minId, error) -> () in
                if error != nil {
                    NSLog("ERROR: TwitterClient.sharedInstance.mentionsTimeline: \(error)")
                } else {
                    self.tweets = mentions!
                    self.minId = minId
                    self.tableView.reloadData()
                }
            })
            
        default:
            NSLog("UNEXPECTED: hamburger menu selected item: \(selectedMenuItem)")
        }
        delegate?.collapseSidePanels?()
    }
}




