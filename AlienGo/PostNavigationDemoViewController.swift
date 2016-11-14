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
    var contentVC: MainFeedDemoViewController! {
        didSet {
            let singleTap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(displayDetailVC))
            singleTap.numberOfTapsRequired = 1
            contentVC.view.addGestureRecognizer(singleTap)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        explanationLabel.text = explanationLabel.text!.replacingOccurrences(of: "$AppName", with: Configuration.readableName)
        
        UserAppState.shouldStartReading = false
    
        self.contentVC.viewModel.navigationDelegate = self
        readExplanationLabel {
            self.contentVC.viewModel.collectionSource.collectionView.reloadData()
            self.explanationLabel.text = "Swipe up or down to have the next or previous post read out loud to you"
            
            self.readExplanationLabel {
                UserAppState.shouldStartReading = true
                self.contentVC.viewModel.collectionSource.collectionView.isScrollEnabled = true
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
            contentVC = (segue.destination as! UINavigationController).topViewController as! MainFeedDemoViewController
        }
    }
    
    @IBAction func skip(_ sender: UIButton) {
        UserAppState.shouldStartReading = true
        readerDelegate.hardStop()
        complete()
    }
    
    func finish() {
        readerDelegate.hardStop()
        UserAppState.hasSeenOnboarding = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.explanationLabel.text = Configuration.onboardingCompleteText
            self.readExplanationLabel {
                self.complete()
            }
        }
    }
    
    func complete() {
        if Configuration.showCategorySelection {
            self.present(self.storyboard!.instantiateViewController(withIdentifier: "NRCategorySelectionViewController"), animated: true, completion: nil)
        } else {
           reloadMainView()
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
        guard UserAppState.shouldStartReading else { return }
        
        if let currentPost = contentVC.viewModel.collectionSource.getCurrentPost() {
            let detailViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: DetailViewController.self)) as! DetailViewController
            
            detailViewController.viewModel = OnboardingDetailViewModel(
                detailPostItem: DetailPost(displayableFeedItem: currentPost),
                displayDelegate: detailViewController,
                onboardingDetailLifecyleDelegate: self,
                onboardingCommentLifecycleDelegate: self
            )
            self.explanationLabel.text = detailExplanationText
            self.explanationLabel.sizeToFit()
            
            contentVC.navigationController?.pushViewController(detailViewController, animated: true)
        }
    }
}

extension PostNavigationDemoViewController: OnboardingDetailLifecycle {
    var readerCallback: ReadingCallbackDelegate {
        return self
    }
    
    var detailExplanationText: String {
        return Configuration.onboardingDetailText
    }
    
    func didReadDetailExplanation() {
        
    }
}

extension PostNavigationDemoViewController: OnboardingCommentLifecycle {
   
    var firstCommentGestureExplanationText: String {
        return "Swipe up to go to the next comment on the same level"
    }
    
    var postSiblingGestureExplanationText: String {
        return "Swipe right to read a comment's reply. Alien Reader will tell you when you've reached the bottom"
    }
    
    var postReplyGestureExplanationText: String {
        return "Double tap at anytime to go to the next top level comment"
    }
    
    var commentExitExplanationText: String {
        return "Long press at anytime to dismiss the comments view"
    }
    
    var commentReaderCallback: ReadingCallbackDelegate {
        return self
    }
    
    func didFinisheReadingFirstComment() {
        self.explanationLabel.text = firstCommentGestureExplanationText
        
        self.readExplanationLabel {
            
        }
    }
    
    func didFinisheReadingReplyExplanation() {
        self.explanationLabel.text = postReplyGestureExplanationText
        
        self.readExplanationLabel {
            
        }
    }
    
    func didFinisheReadingSiblingComment() {
        self.explanationLabel.text = postSiblingGestureExplanationText
        
        self.readExplanationLabel {
            //
        }
    }
    
    func didFinishReadingNextTopLevel() {
        self.explanationLabel.text = commentExitExplanationText
        
        self.readExplanationLabel {
            //
        }
    }
    
    func didDimissComments() {
        self.explanationLabel.text = "Double tap to exit out of the post and return to the main screen"
        
        self.readExplanationLabel {
            //
        }
    }
    
    func readyToDisplayComments(completion: @escaping () -> Void) {
        self.explanationLabel.text = "Once comments are loaded, the first one will be read automatically"
        
        self.readExplanationLabel {
            completion()
        }
    }
}
