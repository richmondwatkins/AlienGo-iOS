//
//  MainCollectionViewCell.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class MainCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subredditLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var visualEffectView: UIVisualEffectView!
    
    func configure(post: DisplayableFeedItem) {
        titleLabel.text = post.postTitle
        
        if let subredditName = post.postSubredditName {
            subredditLabel.text = "/r/\(subredditName)"
        }
        
        usernameLabel.text = post.postedByUsername

        imageView.ra_setImageFromUrlString(urlString: post.content.thumbnailUrl)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
     
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
}

extension MainCollectionViewCell: ReadingCallbackDelegate {
    func willSpeak(_ speechString: String, characterRange: NSRange) {
        if let attString = willSpeakAttrString(fullString: titleLabel.text!, speechString: speechString, range: characterRange, font: titleLabel.font) {
            titleLabel.attributedText = attString
        }
    }
}
