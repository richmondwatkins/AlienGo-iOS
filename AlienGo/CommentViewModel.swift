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
}

class CommentViewModel {

    let detailPostItem: DetailPostItem
    let provider: CommentProvider
    let displayDelegate: CommentDisplayDelegate
    private var readableDelegate: ReadableDelegate = ReadHandler()
    private var orderedComments: [Comment] = []
    private var linearComments: [Comment] = []
    private var readingComment: Comment?
    
    init(detailPostItem: DetailPostItem, displayDelegate: CommentDisplayDelegate) {
        self.detailPostItem = detailPostItem
        self.displayDelegate = displayDelegate
        provider = CommentProvider(detailPostItem: detailPostItem)
    }
    
    func getComments() {
        DispatchQueue.global(qos: .userInitiated).async {
            let response = self.provider.get()
            
            if let first = response.linearComments.first {
              self.read(comment: first)
            }
            
            self.orderedComments = response.orderedComments
            self.linearComments = response.linearComments
            
            self.displayDelegate.display(comments: response.linearComments)
        }
    }
    
    // go back to top comments
    func longPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .ended {
            if let readingComment = readingComment {
                readableDelegate.stopIfNeeded()
                if let topIndex = orderedComments.index(of: readingComment.topLevelParent()), topIndex + 1 < orderedComments.count {
                    let nextTopIndex = topIndex + 1
                    let comment = orderedComments[nextTopIndex]
                    
                    if let liniearIndex = linearComments.index(of: comment) {
                        read(comment: comment)
                        displayDelegate.scrollTo(indexPath: IndexPath(row: liniearIndex, section: 0))
                    }
                }
            }
        }
    }
    
    func didTap(gesture: UITapGestureRecognizer) {
        if let readingComment = readingComment {
            readableDelegate.stopIfNeeded()

            
        }
    }
    
    func didSwipe(gesture: UISwipeGestureRecognizer) {
        if let readingComment = readingComment {
            if gesture.direction == .down {
                readableDelegate.stopIfNeeded()
                
                if let comment = orderedComments.nextSibling(current: readingComment) {
                    goToComment(comment: comment)
                }
            } else if let firstReply = readingComment.replies.first, gesture.direction == .right {
                readableDelegate.stopIfNeeded()
                goToComment(comment: firstReply)
            } else if gesture.direction == .up {
                readableDelegate.stopIfNeeded()
                
                if let previousComment = orderedComments.previous(current: readingComment) {
                    goToComment(comment: previousComment)
                }
            }
        }
    }
    
    func goToComment(comment: Comment) {
        if let liniearIndex = linearComments.index(of: comment) {
            read(comment: comment)
            displayDelegate.scrollTo(indexPath: IndexPath(row: liniearIndex, section: 0))
        }
    }
    
    private func read(comment: Comment) {
        self.readingComment = comment
        self.readableDelegate.readItem(prefixText: "", readableItem: comment)
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
        
        if current.parent == nil {
            if let currentIndex = self.index(of: current), currentIndex + 1 <= self.count {
                return self[currentIndex + 1] as? T
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
            if currentIndex == 0 && current.parent != nil {
                return current.parent as? T
            } else if currentIndex - 1 >= 0 {
                return self[currentIndex - 1] as? T
            }
        }
        
        return nil
    }
    
    func index<T: CommentItem>(of el: T) -> Int? {
        for (index, element) in self.enumerated() {
            if element.id == el.id {
                return index
            }
        }
        
        return nil
    }
}
