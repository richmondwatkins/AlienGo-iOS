//
//  PostNavigationDemoViewController.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/22/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class PostNavigationDemoViewController: UIViewController {

    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var childVCContainer: UIView!
    let readerDelegate: ReadableDelegate = ReadHandler()
    var mainVC: MainViewController!
    override func viewDidLoad() {
        super.viewDidLoad()

        let mainNav = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MainViewControllerNavigationController") as! UINavigationController
        mainVC = mainNav.topViewController as! MainViewController
        
        addChildViewController(mainVC)
        childVCContainer.addSubview(mainVC.view)
        mainNav.didMove(toParentViewController: self)

        readerDelegate.readItem(readableItem: ReaderContainer(text: explanationLabel.text!), delegate: self) { 
            
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let mainVC = mainVC {
            mainVC.view.frame = childVCContainer.bounds
        }
    }
}

extension PostNavigationDemoViewController: ReadingCallbackDelegate {
    
    func willSpeak(_ speechString: String, characterRange: NSRange) {
        explanationLabel.attributedText = willSpeakAttrString(fullString: explanationLabel.text!, speechString: speechString, range: characterRange, font: explanationLabel.font)
    }
}
