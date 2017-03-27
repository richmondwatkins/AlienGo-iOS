//
//  SoundSetupViewController.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/22/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class SoundSetupViewController: UIViewController {

    @IBOutlet weak var explanationlabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.layer.borderWidth = 1.0
            doneButton.layer.cornerRadius = 4.0
            doneButton.layer.borderColor = doneButton.titleLabel?.textColor.cgColor
        }
    }
    @IBOutlet weak var readLabel: UILabel! {
        didSet {
            readLabel.alpha = 0
        }
    }
    var readingExplanation: Bool = true
    weak var readDelegate: ReadableDelegate? = ReadHandler.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        readDelegate?.readItem(readableItem: ReaderContainer(text: explanationlabel.text!), delegate: self, completion: nil)
    }

    @IBAction func sliderChanged(_ sender: UISlider) {
        readingExplanation = false
        UserInfo.utteranceSpeed = sender.value > 0 ? sender.value : 0.0001
        
        UIView.animate(withDuration: 0.3, animations: { 
            self.readLabel.alpha = 1
        }) { (finsihed) in
            self.readDelegate?.readItem(readableItem: ReaderContainer(text: self.readLabel.text!), delegate: self, completion: {
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        readDelegate?.hardStop()
    }
    
    @IBAction func done(_ sender: AnyObject) {
        let postVC: PostNavigationDemoViewController = self.storyboard!.instantiateViewController(withIdentifier: String(describing: PostNavigationDemoViewController.self)) as! PostNavigationDemoViewController
        self.navigationController!.pushViewController(postVC, animated: true)
    }
}

extension SoundSetupViewController: ReadingCallbackDelegate {
    
    func willSpeak(_ speechString: String, characterRange: NSRange) {
        let font: UIFont = readingExplanation ? explanationlabel.font : readLabel.font
        let text: String = readingExplanation ? explanationlabel.text! : readLabel.text!
        let attrText = willSpeakAttrString(fullString: text, speechString: speechString, range: characterRange, font: font)
        
        if readingExplanation {
            explanationlabel.attributedText = attrText
        } else {
            readLabel.attributedText = attrText
        }
    }
}
