//
//  DetailTextViewController.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class DetailTextViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    var textPost: DetailTextItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textView.text = textPost.content
    }
    
    override func viewWillAppear(_ animated: Bool) {
        textView.isScrollEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        textView.isScrollEnabled = true
    }
}

extension DetailTextViewController: ReadingCallbackDelegate {
    func willSpeak(_ speechString: String, characterRange: NSRange) {
        let attrString = NSMutableAttributedString(string: textPost.content)
        
        let font = UIFont(name: "AvenirNext-Regular", size: 18)!
        attrString.addAttributes([NSFontAttributeName: font], range: NSMakeRange(0, textPost.content.characters.count))
        
        attrString.addAttributes([NSForegroundColorAttributeName: UIColor.darkGray, NSFontAttributeName: font], range: characterRange)
        
        textView.attributedText = attrString
    }
}
