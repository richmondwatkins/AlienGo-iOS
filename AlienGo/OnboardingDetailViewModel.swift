//
//  OnboardingDetailViewModel.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/26/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol OnboardingDetailLifecycle {
    var detailExplanationText: String { get }
    var readerCallback: ReadingCallbackDelegate { get }
    func didReadDetailExplanation()
}

class OnboardingDetailViewModel: DetailViewModel {
    var displayDelegate: DetailViewModelDelegate
    var detailPostItem: DetailPostItem
    var onboardingDetailLifecyleDelegate: OnboardingDetailLifecycle
    var onboardingCommentLifecycleDelegate: OnboardingCommentLifecycle
    
    var disappearFromCommentPopover: Bool = false
    var disappearFromSettings: Bool = false
    var readHandler: ReadableDelegate = ReadHandler.shared
    private var shouldAcceptLongPress: Bool = true
    private var readOverviewExplanation: Bool = false
    
    init(detailPostItem: DetailPostItem, displayDelegate: DetailViewModelDelegate, onboardingDetailLifecyleDelegate: OnboardingDetailLifecycle, onboardingCommentLifecycleDelegate: OnboardingCommentLifecycle) {
        self.detailPostItem = detailPostItem
        self.displayDelegate = displayDelegate
        self.onboardingDetailLifecyleDelegate = onboardingDetailLifecyleDelegate
        self.onboardingCommentLifecycleDelegate = onboardingCommentLifecycleDelegate
    }
    
    func showComments(press: UILongPressGestureRecognizer) {
        if press.state == .began && shouldAcceptLongPress {
            
            showCommentVC()
            
            shouldAcceptLongPress = false
        } else if press.state == .ended {
            shouldAcceptLongPress = true
        }
    }
    
    func viewDidDisappear() {
        
    }
    
    func navBack() {
         readHandler.hardStop()
    }
    
    func getInfo() {
        if !readOverviewExplanation {
            readHandler.readItem(readableItem: ReaderContainer(text: onboardingDetailLifecyleDelegate.detailExplanationText), delegate: onboardingDetailLifecyleDelegate.readerCallback) {
                self.onboardingDetailLifecyleDelegate.didReadDetailExplanation()
            }
            
            readOverviewExplanation = true
        }
    }
    
    private func showCommentVC() {
        disappearFromCommentPopover = true
        
        let commentVC: CommentViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: CommentViewController.self)) as! CommentViewController
        
        commentVC.viewModel = OnboardingCommentViewModel(
            detailPostItem: detailPostItem,
            displayDelegate: commentVC,
            onboardingDelegate: onboardingCommentLifecycleDelegate
        )
        
        displayDelegate.present(vc: commentVC)
    }
}
