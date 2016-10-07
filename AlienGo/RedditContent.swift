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
    case imageGallery = "imageGallery"
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
        if let url = url, url.contains("gallery") || url.contains("/a/") {
            self.contentType = .imageGallery
        } else if let url = url, url.contains(".gif") {
            self.contentType = .gif
        } else if let domain = apiResponse["domain"] as? String, domain.contains("reddituploads") || domain.contains("imgur") || domain.contains("streamable") {
            
            if  domain.contains("streamable") {
                self.contentType = .richVideo
            } else {
                self.contentType = .image
            }
            
            if domain.contains("reddituploads") {
                if let url = ((((apiResponse["preview"] as? [String: AnyObject])?["images"] as? [[String: AnyObject]])?.first)?["source"] as? [String: AnyObject])?["url"] as? String {
                    self.url = url
                }
            }
        } else if let postHint = apiResponse["post_hint"] as? String, let contentType = ContentType(rawValue: postHint) {
            self.contentType = contentType
        } else if let isSelf = apiResponse["is_self"] as? Bool, isSelf == true {
            self.contentType = .selfPost
        } else {
            self.contentType = .titleOnly
        }

        if let url = url {
            if contentType == .image && url.contains("imgur") && !url.contains("gif") && !url.contains("jpg") && !url.contains("png") && self.contentType != .imageGallery {
                self.url!.append(".jpg")
            }
        }
    }
    
    func shouldBeShownInWebView() -> Bool {
        return self.contentType == .gif || self.contentType == .imageGallery
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

