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
    @IBOutlet weak var ellipsisView: EllipsisView! {
        didSet {
            ellipsisView.selectionDelegate = self
        }
    }
    var post: DisplayableFeedItem!
    
    func configure(post: DisplayableFeedItem) {
        self.post = post
        
        titleLabel.text = post.postTitle
        subredditLabel.text = post.postSubredditName
        usernameLabel.text = post.author?.username

        imageView.ra_setImageFromUrlString(urlString: post.content.thumbnailUrl)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
     
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        
        configure(post: post)
    }
}

extension MainCollectionViewCell: EllipsisSelectionDelegate {
    
    func didSelect() {
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let reportAction = UIAlertAction(title: "Report", style: .destructive, handler: {
            (alert: UIAlertAction!) -> Void in
            
            NetworkManager.shared.reportPost(postId: self.post.postId)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        
        })

        optionMenu.addAction(reportAction)
        optionMenu.addAction(cancelAction)
        
        let view = UIApplication.shared.keyWindow?.rootViewController?.view
        optionMenu.popoverPresentationController?.sourceView = view

        UIApplication.shared.keyWindow?.rootViewController?.presentViewControllerFromVisibleViewController(viewControllerToPresent: optionMenu, animated: true, completion: nil)
    }
}

extension MainCollectionViewCell: ReadingCallbackDelegate {
    func willSpeak(_ speechString: String, characterRange: NSRange) {
        if let attString = willSpeakAttrString(fullString: titleLabel.text!, speechString: speechString, range: characterRange, font: titleLabel.font) {
            titleLabel.attributedText = attString
        }
    }
}
