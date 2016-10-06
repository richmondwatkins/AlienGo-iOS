//
//  DetailPost.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

struct DetailPost: DetailPostItem {
    internal var title: String

    var content: RedditContent

    init(displayableFeedItem: DisplayableFeedItem) {
        self.content = displayableFeedItem.content
        self.title = displayableFeedItem.postTitle
    }
}
