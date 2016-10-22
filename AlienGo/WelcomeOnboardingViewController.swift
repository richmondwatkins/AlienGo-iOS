//
//  WelcomeOnboardingViewController.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/22/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class WelcomeOnboardingViewController: UIViewController {

    @IBOutlet weak var welcomeLabel: UILabel!
    var readerDelegate: ReadableDelegate = ReadHandler()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        readerDelegate.readItem(readableItem: ReaderContainer(text: welcomeLabel.text!), delegate: self) {
            let soundVC: SoundSetupViewController = self.storyboard!.instantiateViewController(withIdentifier: String(describing: SoundSetupViewController.self)) as! SoundSetupViewController
            self.navigationController!.pushViewController(soundVC, animated: true)
        }
    }
}

extension WelcomeOnboardingViewController: ReadingCallbackDelegate {
    
    func willSpeak(_ speechString: String, characterRange: NSRange) {
      welcomeLabel.attributedText = willSpeakAttrString(fullString: welcomeLabel.text!, speechString: speechString, range: characterRange, font: welcomeLabel.font)
    }
}
