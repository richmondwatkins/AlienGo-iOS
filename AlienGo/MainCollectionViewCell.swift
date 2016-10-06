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
    
    func configure(post: DisplayableFeedItem) {
        titleLabel.text = post.postTitle
    }
}

extension MainCollectionViewCell: ReadingCallbackDelegate {
    func willSpeak(_ speechString: String, characterRange: NSRange) {
        let attrString = NSMutableAttributedString(string: titleLabel.text!)
        
        attrString.addAttributes([NSForegroundColorAttributeName: UIColor.darkGray, NSFontAttributeName: titleLabel.font!], range: characterRange)
        
        titleLabel.attributedText = attrString
    }
}
