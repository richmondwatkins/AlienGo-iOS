//
//  CommentTableViewCell.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/6/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var lableLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var scoreLabel: UILabel!
    var sideLines: [UIView] = []
    let spacing = 12
    let leftSpacing = 6
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var i = 1
        sideLines.forEach { (line) in
            line.frame = CGRect(x: spacing * i - (spacing - leftSpacing), y: 4, width: 1, height: Int(self.frame.height - 4))
            i += 1
        }
    }

    func configure(comment: Comment) {
        commentLabel.text = comment.body
        usernameLabel.text = comment.user.username
        scoreLabel.text = "\(comment.score)"
        
        if comment.user.isOp {
            usernameLabel.textColor = UIColor(ColorConstants.appBlue)
        } else {
            usernameLabel.textColor = .black
        }
        
        lableLeadingConstraint.constant = CGFloat((comment.nestedLevel + 1) * spacing)
        
        for _ in 0..<comment.nestedLevel + 1 {
            let tmpLine = UIView()
            tmpLine.backgroundColor = UIColor("#D3D3D3")
            addSubview(tmpLine)
            
            sideLines.append(tmpLine)
        }
        
        layoutSubviews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        sideLines.forEach { (line) in
            line.removeFromSuperview()
        }
        
        sideLines = []
    }
}

extension CommentTableViewCell: ReadingCallbackDelegate {
    func willSpeak(_ speechString: String, characterRange: NSRange) {
        if let attString = willSpeakAttrString(fullString: commentLabel.text!, speechString: speechString, range: characterRange, font: commentLabel.font) {
            commentLabel.attributedText = attString
        }
    }
}
