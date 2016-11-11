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
    var tmpTextView: UITextView = UITextView()
    var textPost: DetailTextItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tmpTextView.isEditable = false
        tmpTextView.isSelectable = false
        tmpTextView.font = UIFont(name: "AvenirNext-Regular", size: 18)
        tmpTextView.text = textPost.content

        view.addSubview(tmpTextView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tmpTextView.isScrollEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tmpTextView.isScrollEnabled = true
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        tmpTextView.frame = CGRect(x: 8, y: 20, width: view.bounds.width - 16, height: view.bounds.height)
    }
}

extension DetailTextViewController: ReadingCallbackDelegate {
    func willSpeak(_ speechString: String, characterRange: NSRange) {
        DispatchQueue.main.async {
              self.tmpTextView.attributedText = willSpeakAttrString(fullString: self.textPost.content, speechString: speechString, range: characterRange, font: UIFont(name: "AvenirNext-Regular", size: 18)!)
        }
    }
}
