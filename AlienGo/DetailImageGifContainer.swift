//
//  DetailImageGifContainer.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

struct DetailImageGifContainer: DetailImageGifItem {
    internal var isGif: Bool {
        return imageGifUrl.contains("gif")
    }

    var title: String
    var imageGifUrl: String
    
    init?(title: String?, imageGifUrl: String?) {
        guard let title = title,
            let imageGifUrl = imageGifUrl else {
                return nil
        }
        
        self.title = title
        self.imageGifUrl = imageGifUrl
    }
}
