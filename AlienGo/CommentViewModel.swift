//
//  CommentViewModel.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/6/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol CommentDisplayDelegate: class {
    func display(comments: [Comment])
    func dismiss()
    func scrollTo(indexPath: IndexPath)
    func cellForIndex(indexPath: IndexPath) -> CommentTableViewCell?
}

protocol CommentViewModel {
    var detailPostItem: DetailPostItem { get }
    var provider: CommentProvider { get }
    weak var displayDelegate: CommentDisplayDelegate? { get }
    var orderedComments: [Comment] { get }
    var linearComments: [Comment] { get }
    weak var readableDelegate: ReadableDelegate? { get }
    func getComments()
    func goToNextTopLevel()
    func didTap(gesture: UITapGestureRecognizer)
    func didSwipe(gesture: UISwipeGestureRecognizer)
    func dismiss()
   // func read(comment: Comment, index: Int, prefix: String)
}

class MainCommentViewModel: CommentViewModel {

    let detailPostItem: DetailPostItem
    let provider: CommentProvider
    weak var displayDelegate: CommentDisplayDelegate?
    weak var readableDelegate: ReadableDelegate? = ReadHandler.shared
    var orderedComments: [Comment] = []
    var linearComments: [Comment] = []
    private var readingComment: Comment?
    private var shouldAcceptLongPress: Bool = true
    private var isDisplaying: Bool = true
    var readComments: Int = 0
    var firstLoad = true
    init(detailPostItem: DetailPostItem, displayDelegate: CommentDisplayDelegate) {
        self.detailPostItem = detailPostItem
        self.displayDelegate = displayDelegate
        provider = CommentProvider(detailPostItem: detailPostItem, repository: MainCommentRepository())
    }
    
    func getComments() {

        if firstLoad {
            firstLoad = false
            readableDelegate?.hardStop()
            var readingFinished = false
            readableDelegate?.readItem(readableItem: ReaderContainer(text: "Loading Comments"), delegate: nil, completion: {
                readingFinished = true
            })
            
            DispatchQueue.global(qos: .userInitiated).async {
                let response = self.provider.get()
                
                self.orderedComments = response.orderedComments
                self.linearComments = response.linearComments
                
                self.displayDelegate?.display(comments: self.linearComments)
                
                if let first = self.linearComments.first {
                    //hack 
                    while !readingFinished {}
                    self.read(comment: first, index: 0)
                }
            }
        }
    }
    
    // go back to top comments
    func goToNextTopLevel() {
        if let readingComment = readingComment {
            if let topIndex = orderedComments.index(of: readingComment.topLevelParent()), topIndex + 1 < orderedComments.count {
                let nextTopIndex = topIndex + 1
                let comment = orderedComments[nextTopIndex]
                
                goToComment(comment: comment)
            }
        }
    }
    
    func didTap(gesture: UITapGestureRecognizer) {
        if let readingComment = readingComment {
            let usernameReadable = readingComment.user.isOp ? "\(readingComment.user.username) the O P" : readingComment.user.username
            self.readableDelegate?.readItem(readableItem: ReaderContainer(text: "Comment by \(usernameReadable)   score of \(readingComment.score) \(readingComment.text)"), delegate: nil, completion: nil)
        }
    }
    
    func didSwipe(gesture: UISwipeGestureRecognizer) {
        if let readingComment = readingComment {
            if gesture.direction == .up {
               goToNextSibling()
            } else if gesture.direction == .right || gesture.direction == .left {
               goToReply()
            } else if gesture.direction == .down {
                if let previousComment = orderedComments.previous(current: readingComment) {
                    goToComment(comment: previousComment)
                } else {
                    self.readableDelegate?.readItem(readableItem: ReaderContainer(text: "No more previous comments. Try swiping down."), delegate: nil, completion: nil)
                }
            }
        }
    }
    
    func dismiss() {
        isDisplaying = false
        readableDelegate?.hardStop()
        displayDelegate?.dismiss()
    }
    
    private func goToReply() {
        if let readingComment = readingComment {
            if let firstReply = readingComment.replies.first {
                goToComment(comment: firstReply, prefix: "Reply by")
            } else {
                if StateProvider.isAuto {
                    goToNextTopLevel()
                } else {
                     self.readableDelegate?.readItem(readableItem: ReaderContainer(text: "No more replies. Double tap to go to next top level comment"), delegate: nil, completion: nil)
                }
            }
        }
    }
    
    private func goToNextSibling() {
        if let readingComment = readingComment {
            if let comment = orderedComments.nextSibling(current: readingComment) {
                goToComment(comment: comment)
            } else {
                self.readableDelegate?.readItem(readableItem: ReaderContainer(text: "No more sibling comments"), delegate: nil, completion: nil)
            }
        }
    }
    
    private func goToComment(comment: Comment, prefix: String = "Comment by") {
        if let liniearIndex = linearComments.index(of: comment) {
           
            displayDelegate?.scrollTo(indexPath: IndexPath(row: liniearIndex, section: 0))
            
            read(comment: comment, index: liniearIndex, prefix: prefix)
        }
    }
    
    func read(comment: Comment, index: Int, prefix: String = "Comment by") {
        readComments += 1
        readingComment = comment
        let userReadText = comment.user.isOp ? "\(comment.user.username), the O P" : comment.user.username
        let userReadItem = ReaderContainer(text: userReadText)
        
        readableDelegate?.hardStop()
        // hack for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            if let cell = self.displayDelegate?.cellForIndex(indexPath: IndexPath(row: index, section: 0)) {
                self.readableDelegate?.readItem(readableItem: ReaderContainer(text: "\(prefix)  \(userReadItem.text)"), delegate: nil, completion: {
                    self.readableDelegate?.hardStop()
                    self.readableDelegate?.readItem(readableItem: comment, delegate: cell, completion: {
                        if StateProvider.isAuto && self.isDisplaying {
                            if self.readComments == 6 {
                                self.displayDelegate?.dismiss()
                                return
                            }
                            
                            if comment.nestedLevel == 0 {
                                self.goToReply()
                            } else {
                                self.goToNextTopLevel()
                            }
                        }
                    })
                })
            }
        })
    }
}

extension Comment {
    
    func topLevelParent() -> Comment {
        var comment: Comment = self
        var parent: Comment? = self.parent
        
        while parent != nil {
            if let newParent = parent {
                comment = newParent
            }
            
            parent = comment.parent
        }
        
       return comment
    }
}

extension Array where Element:CommentItem {
    
    func nextSibling<T: CommentItem>(current: T) -> T? {
        guard let parent = current.parent else {
            if let currentIndex = self.index(of: current), currentIndex + 1 <= self.count {
                return self[currentIndex + 1] as? T
            }
            
            return nil
        }
        if let currentIndex = parent.replies.index(of: current) {
            if currentIndex + 1 < parent.replies.count {
                return parent.replies[currentIndex + 1] as? T
            }
        }
        
        return nil
    }
    
    func previous<T: CommentItem>(current: T) -> T? {
        guard let parent = current.parent else {
            if let currentIndex = self.index(of: current), currentIndex - 1 >= 0 {
                return self[currentIndex - 1] as? T
            }
            
            return nil
        }
   
        if let currentIndex = parent.replies.index(of: current) {
            if currentIndex == 0 {
                return current.parent as? T
            } else if currentIndex - 1 >= 0 {
                return self[currentIndex - 1] as? T
            }
        }
        
        return nil
    }
    
    func index<T: CommentItem>(of el: T) -> Int? {
        var i = 0
        for element in self {
            if element.id == el.id {
                return i
            }
            
            i += 1
        }
        
        return nil
    }
}
