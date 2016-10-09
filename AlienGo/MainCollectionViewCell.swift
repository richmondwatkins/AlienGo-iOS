//
//  MainCollectionViewCell.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subredditLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    
    func configure(post: DisplayableFeedItem) {
        titleLabel.text = post.postTitle
        
        if let subredditName = post.postSubredditName {
            subredditLabel.text = "/r/\(subredditName)"
        }
        
        usernameLabel.text = post.postedByUsername
    }
}

extension MainCollectionViewCell: ReadingCallbackDelegate {
    func willSpeak(_ speechString: String, characterRange: NSRange) {
        titleLabel.attributedText = willSpeakAttrString(fullString: titleLabel.text!, range: characterRange, font: titleLabel.font)
    }
}
