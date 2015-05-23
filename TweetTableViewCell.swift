//
//  TweetTableViewCell.swift
//  Warble
//
//  Created by Monica Sun on 5/21/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var screename: UILabel!
    
    @IBOutlet weak var tweetText: UILabel!
    @IBOutlet weak var timestamp: UILabel!
    
    var imageUrlString = String()
    
    var tweet: Tweet! {
        didSet {
            name.text = tweet.user?.name
            imageUrlString = tweet.user?.profileImageUrl as String!
            profileImage.setImageWithURL(NSURL(string: imageUrlString))
            screename.text = "@" + (tweet.user?.username as String!)
            tweetText.text = tweet.text
            timestamp.text = tweet.createdAtString
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImage.layer.cornerRadius = 5
        profileImage.clipsToBounds = true
        profileImage.frame.size.width = 25
        profileImage.frame.size.height = 50
        profileImage.contentMode = UIViewContentMode.ScaleAspectFit
        
        name.preferredMaxLayoutWidth = name.frame.size.width
        name.numberOfLines = 1
        screename.numberOfLines = 1
        name.font = UIFont(name: "AppleSDGothicNeo-Regular", size: CGFloat(12))
        screename.font = UIFont(name: "AppleSDGothicNeo-Regular", size: CGFloat(10))
        
        tweetText.numberOfLines = 0
        tweetText.font = UIFont(name: "AppleSDGothicNeo-Regular", size: CGFloat(12))
        timestamp.numberOfLines = 1
        timestamp.font = UIFont(name: "AppleSDGothicNeo-Regular", size: CGFloat(10))
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        name.preferredMaxLayoutWidth = name.frame.size.width
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
