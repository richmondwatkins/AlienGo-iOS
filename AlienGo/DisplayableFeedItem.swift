//
//  DisplayableFeedItem.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol DisplayableFeedItem: Readable {
    var postId: String { get }
    var postPermalink: String { get }
    var postName: String { get }
    var postTitle: String { get }
    var postSubredditName: String? { get }
    var author: User? { get }
    var content: RedditContent { get }
}
