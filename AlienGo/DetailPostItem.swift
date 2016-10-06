//
//  DetailPostItem.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol DetailPostItem {
    var content: RedditContent { get }
    var title: String { get }
    var id: String { get }
    var permalink: String { get }
}
