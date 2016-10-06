//
//  CommentProvider.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/6/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class CommentProvider {

    lazy var repository: CommentRepository = CommentRepository()
    let detailPostItem: DetailPostItem
    
    init(detailPostItem: DetailPostItem) {
        self.detailPostItem = detailPostItem
    }
    
    func get() -> (linearComments: [Comment], orderedComments: [Comment]) {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        var retval:(linearComments: [Comment], orderedComments: [Comment]) = ([Comment](), [Comment]())
        
        repository.get(detailPostItem: detailPostItem) { (linearComments, orderedComments, error) in
            retval.linearComments = linearComments ?? [Comment]()
            retval.orderedComments = orderedComments ?? [Comment]()
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return retval
    }
}
