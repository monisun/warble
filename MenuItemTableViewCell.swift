//
//  MenuItemTableViewCell.swift
//  Warble
//
//  Created by Monica Sun on 5/31/15.
//  Copyright (c) 2015 Monica Sun. All rights reserved.
//

import UIKit

class MenuItemTableViewCell: UITableViewCell {
    
    var menuItem: String?
    @IBOutlet weak var menuLabel: UILabel!

    @IBOutlet weak var menuItemImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        // styling
        menuLabel.textAlignment = NSTextAlignment.Left
        menuLabel.font = UIFont(name: "HelveticaNeue", size: 20)
        menuLabel.numberOfLines = 1
        menuItemImageView.layer.cornerRadius = 5
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }
}
