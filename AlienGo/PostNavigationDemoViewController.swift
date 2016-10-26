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
    let readerDelegate: ReadableDelegate = ReadHandler.shared
    var contentVC: MainFeedDemoViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(false, forKey: "shouldStartReading")
        UserDefaults.standard.synchronize()
        
        self.contentVC.viewModel.collectionSource.collectionView.isScrollEnabled = false
        self.contentVC.viewModel.navigationDelegate = self
        readExplanationLabel {
            self.contentVC.viewModel.collectionSource.collectionView.reloadData()
            self.explanationLabel.text = "Swipe up or down to have the next or previous post read out loud to you. I will go ahead and read the first one for you"
            
            self.readExplanationLabel {
                UserDefaults.standard.set(true, forKey: "shouldStartReading")
                UserDefaults.standard.synchronize()
                self.contentVC.viewModel.collectionSource.collectionView.isScrollEnabled = true
                self.contentVC.viewModel.readFirst()
            }
        }
    }
    
    func readExplanationLabel(callback: @escaping () -> Void) {
        readerDelegate.readItem(readableItem: ReaderContainer(text: explanationLabel.text!), delegate: self) {
            
            callback()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ContentSegue" {
            contentVC = segue.destination as! MainFeedDemoViewController
        }
    }
}

extension PostNavigationDemoViewController: ReadingCallbackDelegate {
    
    func willSpeak(_ speechString: String, characterRange: NSRange) {
        explanationLabel.attributedText = willSpeakAttrString(fullString: explanationLabel.text!, speechString: speechString, range: characterRange, font: explanationLabel.font)
    }
}

extension PostNavigationDemoViewController: RedditPostListingNavigationDelegate {
    
    func didFinishReadingAfterSwipe(direction: ScrollDirection) {
        self.contentVC.viewModel.collectionSource.collectionView.isScrollEnabled = false
        self.explanationLabel.text = "Nice job! Now touch the post to reveal it's content"
        
        self.readExplanationLabel {
            
        }
    }
    
    func displayDetailVC() {
        
    }
}

