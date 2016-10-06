//
//  DisplayableFeedItem.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol DisplayableFeedItem: Readable {
    var postTitle: String { get }
    var postPhotoURL: String? { get }
    var content: RedditContent { get }
}
