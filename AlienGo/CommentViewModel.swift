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
}

class CommentViewModel {

    let detailPostItem: DetailPostItem
    let provider: CommentProvider
    let displayDelegate: CommentDisplayDelegate
    private var readableDelegate: ReadableDelegate = ReadHandler()
    private var orderedComments: [Comment] = []
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
                self.readingComment = first
                self.readableDelegate.readItem(prefixText: "", readableItem: response.linearComments.first!)
            }
            
            self.orderedComments = response.orderedComments
            self.displayDelegate.display(comments: response.linearComments)
        }
    }
    
    func didTap(gesture: UITapGestureRecognizer) {
        
    }
    
    func didSwipe(gesture: UISwipeGestureRecognizer) {
        
    }
}
