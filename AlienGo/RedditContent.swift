//
//  RedditContent.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

enum ContentType: String {
    case image = "image"
    case link = "link"
    case selfPost = "self"
    case gif = "gif"
    case richVideo = "rich:video"
    case titleOnly = "titleOnly"
}
struct RedditContent {
    
    var selfText: String?
    var url: String?
    var contentType: ContentType

    init(apiResponse: [String: AnyObject]) {
        selfText = apiResponse["selftext"] as? String
        url = apiResponse["url"] as? String
        
        //order of conditional matters
        if let domain = apiResponse["domain"] as? String, domain.contains("reddituploads") || domain.contains("imgur") {
            self.contentType = .image
        } else if let url = url, url.contains(".gif") {
            self.contentType = .gif
        } else if let postHint = apiResponse["post_hint"] as? String, let contentType = ContentType(rawValue: postHint) {
            self.contentType = contentType
        } else {
            self.contentType = .titleOnly
        }
        
        if let url = url {
            if contentType == .image && url.contains("imgur") && !url.contains("gif") && !url.contains("jpg") && !url.contains("png") && !url.contains("gallery") {
                self.url!.append(".jpg")
            }
        }
    }
    
    func requestBodyValue() -> String? {
        if let selfText = selfText, !selfText.isEmpty {
            return selfText
        }
        
        if let url = url, contentType == .link {
            return url
        }
        
        return nil
    }
}

