//
//  OnboardingCommentViewModel.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/26/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol OnboardingCommentLifecycle {
    var firstCommentGestureExplanationText: String { get }
    var postSiblingGestureExplanationText: String { get }
    var postReplyGestureExplanationText: String { get }
    var commentExitExplanationText: String { get }
    var commentReaderCallback: ReadingCallbackDelegate { get }
    func didFinisheReadingFirstComment()
    func didFinisheReadingSiblingComment()
    func didFinisheReadingReplyExplanation()
    func didFinishReadingNextTopLevel()
    func didDimissComments()
    func readyToDisplayComments(completion: @escaping () -> Void)
}

enum OnboardingCommentReadingState {
    case readingFirst
    case readingSibling
    case readingReply
    case readingTopLevel
    case notNeededForOnboarding
}

class OnboardingCommentViewModel: CommentViewModel {

    var detailPostItem: DetailPostItem
    var provider: CommentProvider
    weak var displayDelegate: CommentDisplayDelegate?
    var readableDelegate: ReadableDelegate = ReadHandler.shared
    var orderedComments: [Comment] = []
    var linearComments: [Comment] = []
    private var readingComment: Comment?
    var commentReadCount = 0
    let onboardingDelegate: OnboardingCommentLifecycle
    var onboardingReadingState: OnboardingCommentReadingState = .readingFirst
    
    init(detailPostItem: DetailPostItem, displayDelegate: CommentDisplayDelegate, onboardingDelegate: OnboardingCommentLifecycle) {
        self.detailPostItem = detailPostItem
        self.displayDelegate = displayDelegate
        provider = CommentProvider(detailPostItem: detailPostItem, repository: OnboardingCommentRepository())
        self.onboardingDelegate = onboardingDelegate
    }
    
    func getComments() {
        onboardingDelegate.readyToDisplayComments {
            DispatchQueue.global(qos: .userInitiated).async {
                let response = self.provider.get()
                
                self.orderedComments = response.orderedComments
                self.linearComments = response.linearComments
                
                self.displayDelegate?.display(comments: response.linearComments)
                
                if let first = response.linearComments.first {
                    self.read(comment: first, index: 0, toOnboardingState: .readingFirst)
                }
            }
        }
    }
    
    func goToNextTopLevel() {
        if let readingComment = readingComment {
            if let topIndex = orderedComments.index(of: readingComment.topLevelParent()), topIndex + 1 < orderedComments.count {
                let nextTopIndex = topIndex + 1
                let comment = orderedComments[nextTopIndex]
                
                goToComment(comment: comment, toOnboardingState: .readingTopLevel)
            }
        }
    }
    
    func didTap(gesture: UITapGestureRecognizer) {
       
    }
    
    func didSwipe(gesture: UISwipeGestureRecognizer) {
        if let readingComment = readingComment {
            if gesture.direction == .up {
                goToNextSibling()
            } else if gesture.direction == .right {
                goToReply()
            } else if gesture.direction == .down {
                if let previousComment = orderedComments.previous(current: readingComment) {
                    goToComment(comment: previousComment, toOnboardingState: .notNeededForOnboarding)
                } else {
                    self.readableDelegate.readItem(readableItem: ReaderContainer(text: "No more previous comments."), delegate: nil, completion: nil)
                }
            }
        }
    }
    
    private func goToReply() {
        if let readingComment = readingComment {
            if let firstReply = readingComment.replies.first {
                goToComment(comment: firstReply, toOnboardingState: .readingReply, prefix: "Reply by")
            } else {
                if StateProvider.isAuto {
                    goToNextTopLevel()
                } else {
                    self.readableDelegate.readItem(readableItem: ReaderContainer(text: "No more replies. Double tap to go to the next top level comment"), delegate: nil, completion: nil)
                }
            }
        }
    }
    
    private func goToNextSibling() {
        if let readingComment = readingComment {
            if let comment = orderedComments.nextSibling(current: readingComment) {
                goToComment(comment: comment, toOnboardingState: .readingSibling)
            } else {
                self.readableDelegate.readItem(readableItem: ReaderContainer(text: "No more sibling comments"), delegate: nil, completion: nil)
            }
        }
    }
    
    private func goToComment(comment: Comment, toOnboardingState: OnboardingCommentReadingState, prefix: String = "Comment by") {
        if let liniearIndex = linearComments.index(of: comment) {
            
            displayDelegate?.scrollTo(indexPath: IndexPath(row: liniearIndex, section: 0))
            
            read(comment: comment, index: liniearIndex, toOnboardingState: toOnboardingState, prefix: prefix)
        }
    }
    
    func dismiss() {
        readableDelegate.hardStop()
        displayDelegate?.dismiss()
        onboardingDelegate.didDimissComments()
    }
    
    func read(comment: Comment, index: Int, toOnboardingState: OnboardingCommentReadingState, prefix: String = "") {
        let userReadItem = ReaderContainer(readable: comment.user)
        readingComment = comment
        readableDelegate.hardStop()
        self.commentReadCount += 1
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            if let cell = self.displayDelegate?.cellForIndex(indexPath: IndexPath(row: index, section: 0)) {
                self.readableDelegate.readItem(readableItem: ReaderContainer(text: "\(prefix)  \(userReadItem.text)"), delegate: nil, completion: {
                    self.readableDelegate.readItem(readableItem: comment, delegate: cell, completion: {
                
                        if self.commentReadCount >= 4 {
                            self.onboardingDelegate.didFinishReadingNextTopLevel()
                            return
                        }
                        
                        switch toOnboardingState {
                        case .readingFirst:
                             self.onboardingDelegate.didFinisheReadingFirstComment()
                            break
                        case .readingReply:
                            self.onboardingDelegate.didFinisheReadingReplyExplanation()
                            break
                        case .readingSibling:
                              self.onboardingDelegate.didFinisheReadingSiblingComment()
                            break
                        case .readingTopLevel where self.commentReadCount < 4:
                            self.onboardingDelegate.didFinisheReadingFirstComment()
                            break
                        case .readingTopLevel where self.commentReadCount > 4:
                            self.onboardingDelegate.didFinishReadingNextTopLevel()
                            break
                        case .notNeededForOnboarding where self.commentReadCount > 1:
                             self.onboardingDelegate.didFinishReadingNextTopLevel()
                            break
                        default:
                            break
                        }
                    })
                })
            }
        })
    }
}
