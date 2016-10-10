//
//  CommentTableViewCell.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/6/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var lableLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(comment: Comment) {
        commentLabel.text = comment.body
        
        lableLeadingConstraint.constant = CGFloat((comment.nestedLevel + 1) * 8)
    }
}

extension CommentTableViewCell: ReadingCallbackDelegate {
    func willSpeak(_ speechString: String, characterRange: NSRange) {
         commentLabel.attributedText = willSpeakAttrString(fullString: commentLabel.text!, range: characterRange, font: commentLabel.font)
    }
}
