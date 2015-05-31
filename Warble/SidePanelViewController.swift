//
//  SidePanelViewController.swift
//  Warble
//
//  Created by Monica Sun on 5/31/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

@objc protocol SidePanelViewControllerDelegate {
    func menuItemSelected(selectedMenuItem: String)
}


class SidePanelViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var logoImageView: UIImageView!
    
    var delegate: SidePanelViewControllerDelegate?
    
    let menuItems = ["profile", "home", "mentions"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.reloadData()
        
        // animate logo
        let blurEffect: UIBlurEffect = UIBlurEffect(style: .Dark)
        let blurView: UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurView.setTranslatesAutoresizingMaskIntoConstraints(false)
        logoImageView.addSubview(blurView)
        
        let originalCenter = logoImageView.center
        
        UIView.animateWithDuration(0.6, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1.0, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.logoImageView.center.x += 200
            self.logoImageView.center.y += 200
        }, completion: { (Bool) -> Void in
            self.logoImageView.center = originalCenter
        })
    }
    
    override func viewDidAppear(animated: Bool) {
        
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
        return menuItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell", forIndexPath: indexPath) as! MenuItemTableViewCell
        
        if menuItems.count > indexPath.row {
            if indexPath.row == 0 {
                // show profile image
                let currentUserProfileImageUrl = User.currentUser?.profileImageUrl
                cell.menuItemImageView.setImageWithURL(NSURL(string: currentUserProfileImageUrl!))
            } else {
                var menuIconImage = UIImage(named: menuItems[indexPath.row])
                cell.menuItemImageView.image = menuIconImage
            }
            
            cell.menuItem = menuItems[indexPath.row]
            cell.menuLabel.text = menuItems[indexPath.row].uppercaseString
            
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedMenuItem = menuItems[indexPath.row]
        delegate?.menuItemSelected(selectedMenuItem)
    }

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}




