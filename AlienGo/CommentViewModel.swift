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
    
    func didTap(gesture: UITapGestureRecognizer) {
        readableDelegate.stopIfNeeded()
        if let readingComment = readingComment {
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
    
    func didSwipe(gesture: UISwipeGestureRecognizer) {
        readableDelegate.stopIfNeeded()
    }
    
    private func read(comment: Comment) {
        self.readingComment = comment
        self.readableDelegate.readItem(prefixText: "", readableItem: comment)
    }
}

extension Comment {
    
    func topLevelParent() -> Comment {
        guard let parent = self.parent else {
            return self
        }
        
       return parent.topLevelParent()
    }
}
