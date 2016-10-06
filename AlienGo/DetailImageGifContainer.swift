//
//  DetailImageGifContainer.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

struct DetailImageGifContainer: DetailImageGifItem {
    var title: String
    var showInWebView: Bool
    var imageGifUrl: String
    
    init?(title: String?, imageGifUrl: String?, showInWebView: Bool) {
        guard let title = title,
            let imageGifUrl = imageGifUrl else {
                return nil
        }
        
        self.title = title
        self.showInWebView = showInWebView
        self.imageGifUrl = imageGifUrl
    }
}
