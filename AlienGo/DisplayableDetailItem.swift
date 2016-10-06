//
//  DisplayableDetailItem.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol DetailTextItem: DetailItem {
    var content: String { get }
    init?(title: String?, content: String?)
}

protocol DetailImageGifItem: DetailItem {
    var imageGifUrl: String { get }
    var isGif: Bool { get }
    init?(title: String?, imageGifUrl: String?)
}
