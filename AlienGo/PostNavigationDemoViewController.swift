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
        
        UserDefaults.standard.set(false, forKey: "shouldStartReading")
        UserDefaults.standard.synchronize()
        
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
            contentVC = (segue.destination as! UINavigationController).topViewController as! MainFeedDemoViewController
        }
    }
    
    @IBAction func skip(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "shouldStartReading")
        UserDefaults.standard.synchronize()
        readerDelegate.hardStop()
        complete()
    }
    
    func finish() {
        readerDelegate.hardStop()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { 
            self.explanationLabel.text = "That's it! Thanks for making it this far. This view will reload and you will be good to go."
            self.readExplanationLabel {
                self.complete()
            }
        }
    }
    
    func complete() {
        UserAppState.hasSeenOnboarding = true

        let navId: String = "MainViewControllerNavigationController"
        let storyboard: String = "Main"
        
        (UIApplication.shared.delegate as! AppDelegate).window?.rootViewController = UIStoryboard(name: storyboard, bundle: Bundle.main).instantiateViewController(withIdentifier: navId)
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
        return "Alien Reader tries to pull any text it can from a post. If it is unable to it will tell you so. We will skip this content for now and demo comments. Long press anywhere on the screen to display them"
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
