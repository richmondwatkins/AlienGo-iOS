//
//  SubscribedSubredditTableViewCell.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/19/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class SubscribedSubredditTableViewCell: UITableViewCell {

    @IBOutlet weak var subredditNameLabel: UILabel!
    @IBOutlet weak var subredditIconImageView: UIImageView!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    
    func configure(subreddit: SettingSubscribedCategory) {
        subredditNameLabel.text = subreddit.text
        
        if let iconURL = subreddit.iconURL, let url = URL(string: iconURL) {
            subredditIconImageView.ra_setImageFromURL(url: url)
        } else {
            if let image = UIImage(named: "redditLogo") {
                subredditIconImageView.image = image
            } else {
                imageViewWidthConstraint.constant = 0
                layoutIfNeeded()
            }
        }
    }
}
