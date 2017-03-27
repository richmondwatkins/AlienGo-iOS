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
    weak var readerDelegate: ReadableDelegate? = ReadHandler.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        welcomeLabel.text = Configuration.onboardingOpeningText

        readerDelegate?.readItem(readableItem: ReaderContainer(text: welcomeLabel.text!), delegate: self) {
            self.goToNextScreen()
        }
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(goToNextScreen))
        tapGesture.numberOfTapsRequired = 1
        
        view.addGestureRecognizer(tapGesture)
    }
    
    func goToNextScreen() {
        let soundVC: SoundSetupViewController = self.storyboard!.instantiateViewController(withIdentifier: String(describing: SoundSetupViewController.self)) as! SoundSetupViewController
        DispatchQueue.main.async {
            self.navigationController!.pushViewController(soundVC, animated: true)
        }
    }
}

extension WelcomeOnboardingViewController: ReadingCallbackDelegate {
    
    func willSpeak(_ speechString: String, characterRange: NSRange) {
      welcomeLabel.attributedText = willSpeakAttrString(fullString: welcomeLabel.text!, speechString: speechString, range: characterRange, font: welcomeLabel.font)
    }
}
