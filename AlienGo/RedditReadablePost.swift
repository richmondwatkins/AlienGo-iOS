//
//  RedditReadable.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

struct RedditReadablePost: Readable {

    var text: String
    var readCompletionHandler: (() -> Void)?
    
    init(displayablePost: DisplayableFeedItem) {
        self.text = displayablePost.postTitle
    }
}
