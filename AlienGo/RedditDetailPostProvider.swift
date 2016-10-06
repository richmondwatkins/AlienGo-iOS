//
//  RedditDetailPostProvider.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class RedditDetailPostProvider: NSObject {

    var repository: RedditPostDetailRepository!
    let detailPost: DetailPostItem
    
    init(detailPost: DetailPostItem) {
        self.detailPost = detailPost
        repository = RedditPostDetailRepository(detailPost: detailPost)
    }
    
    func get() -> DetailTextItem? {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        var retVal: DetailTextItem?
        
        repository.get { (detailItem) in
            retVal = detailItem
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return retVal
    }
}
