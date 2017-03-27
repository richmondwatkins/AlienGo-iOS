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
    case selfPostTitleOnly = "selfPostTitleOnly"
    case gif = "gif"
    case richVideo = "rich:video"
    case titleOnly = "titleOnly"
}
struct RedditContent {
    
    var selfText: String?
    var url: String?
    var contentType: ContentType
    var thumbnailUrl: String?

    init(apiResponse: [String: AnyObject]) {
        selfText = (apiResponse["selftext"] as? String)?.trim()
        url = apiResponse["url"] as? String
        thumbnailUrl = apiResponse["thumbnail"] as? String
  
        //order of conditional matters
        if let url = url, url.contains("gallery") || url.contains("/a/") {
            self.contentType = .imageGallery
        } else if let url = url, url.contains(".gif") {
            self.contentType = .gif
        } else if let domain = apiResponse["domain"] as? String, domain.contains("reddituploads") || domain.contains("imgur") || domain.contains("streamable") {
            
            if domain.contains("streamable") {
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
            if apiResponse["selftext_html"] is NSNull {
                self.contentType = .selfPostTitleOnly
            } else {
                self.contentType = .selfPost
            }
        } else if let _ = url {
            self.contentType = .link
        } else {
            self.contentType = .titleOnly
        }

        if let url = url {
            if contentType == .image && url.contains("imgur") && !url.contains("gif") && !url.contains("jpg") && !url.contains("png") && self.contentType != .imageGallery {
                self.url!.append(".jpg")
            }
        }
    }
    
    init?(nytApiResponse: [String: AnyObject]) {
        self.contentType = .link
        
        guard let url = nytApiResponse["url"] as? String,
            let multimedia = nytApiResponse["multimedia"] as? [[String: AnyObject]],
            let sourceUrl = multimedia.first?["url"] as? String else {
                return nil
        }
        
        self.url = url
        self.thumbnailUrl = sourceUrl
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

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
