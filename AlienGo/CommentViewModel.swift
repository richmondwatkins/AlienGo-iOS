//
//  CommentViewModel.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/6/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol CommentDisplayDelegate {
    func display(comments: [Comment])
    func scrollTo(indexPath: IndexPath)
    func cellForIndex(indexPath: IndexPath) -> CommentTableViewCell?
}

class CommentViewModel {

    let detailPostItem: DetailPostItem
    let provider: CommentProvider
    let displayDelegate: CommentDisplayDelegate
    private var readableDelegate: ReadableDelegate = ReadHandler()
    private lazy var metaDetailReader: ReadableDelegate = ReadHandler()
    private var orderedComments: [Comment] = []
    private var linearComments: [Comment] = []
    private var readingComment: Comment?
    private var shouldAcceptLongPress: Bool = true
    
    init(detailPostItem: DetailPostItem, displayDelegate: CommentDisplayDelegate) {
        self.detailPostItem = detailPostItem
        self.displayDelegate = displayDelegate
        provider = CommentProvider(detailPostItem: detailPostItem)
    }
    
    func getComments() {
        DispatchQueue.global(qos: .userInitiated).async {
            let response = self.provider.get()
        
            self.orderedComments = response.orderedComments
            self.linearComments = response.linearComments
            
            self.displayDelegate.display(comments: response.linearComments)
            
            if let first = response.linearComments.first {
                self.read(comment: first, index: 0)
            }
        }
    }
    
    // go back to top comments
    func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began && shouldAcceptLongPress {
            
            if let readingComment = readingComment {
                if let topIndex = orderedComments.index(of: readingComment.topLevelParent()), topIndex + 1 < orderedComments.count {
                    let nextTopIndex = topIndex + 1
                    let comment = orderedComments[nextTopIndex]
                    
                    goToComment(comment: comment)
                }
            }
            
            shouldAcceptLongPress = false
        } else if gesture.state == .ended {
            shouldAcceptLongPress = true
        }
    }
    
    func didTap(gesture: UITapGestureRecognizer) {
        if let readingComment = readingComment {
             self.readableDelegate.readItem(prefixText: "Comment by \(readingComment.user.username)   score of \(readingComment.score)", readableItem: readingComment)
        }
    }
    
    func didSwipe(gesture: UISwipeGestureRecognizer) {
        if let readingComment = readingComment {
            if gesture.direction == .down {
                if let comment = orderedComments.nextSibling(current: readingComment) {
                    goToComment(comment: comment)
                } else {
                    self.readableDelegate.readItem(prefixText: "", readableItem: ReaderContainer(text: "No more sibling comments"))
                }
            } else if gesture.direction == .right {
                if let firstReply = readingComment.replies.first {
                    goToComment(comment: firstReply)
                } else {
                    self.readableDelegate.readItem(prefixText: "", readableItem: ReaderContainer(text: "No more replies. Long press to go to next top level comment"))
                }
            } else if gesture.direction == .up {
                if let previousComment = orderedComments.previous(current: readingComment) {
                    goToComment(comment: previousComment)
                } else {
                    self.readableDelegate.readItem(prefixText: "", readableItem: ReaderContainer(text: "No more previous comments. Try swiping down."))
                }
            }
        }
    }
    
    func goToComment(comment: Comment) {
        if let liniearIndex = linearComments.index(of: comment) {
           
            displayDelegate.scrollTo(indexPath: IndexPath(row: liniearIndex, section: 0))
            
            read(comment: comment, index: liniearIndex)
        }
    }
    
    func dismiss() {
        readableDelegate.stopIfNeeded()
    }
    
    private func read(comment: Comment, index: Int) {
        self.readingComment = comment
        
        let userReadItem = ReaderContainer(readable: comment.user)
        
        self.readableDelegate.readItem(prefixText: "Comment by  \(userReadItem.text)", readableItem: comment)
        
        // hack for now
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            if let cell = self.displayDelegate.cellForIndex(indexPath: IndexPath(row: index, section: 0)) {
                self.readableDelegate.setReadingCallback(delegate: cell)
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
