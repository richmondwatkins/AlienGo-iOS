//
//  RedditReadable.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

struct RedditReadablePost: Readable {

    var postId: String
    var text: String
    var subredditName: String?
    var author: User?
    
    init(displayablePost: DisplayableFeedItem) {
        self.postId = displayablePost.postId
        self.text = displayablePost.postTitle
        self.author = displayablePost.author
        self.subredditName = displayablePost.postSubredditName
    }
}
