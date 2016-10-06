//
//  RedditPost.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

struct RedditPost {

    let subreddit: Subreddit
    let previewPhoto: PreviewPhoto
    var content: RedditContent
    let id: String
    let title: String
    var author: String?
    var score: Int?
    
    init?(apiResponse: [String: AnyObject]) {
        guard let data = apiResponse["data"] as? [String: AnyObject],
            let subreddit = Subreddit(apiResponse: data),
            let id = data["id"] as? String,
            let previewPhoto = PreviewPhoto(apiResponse: data),
            let title = data["title"] as? String else {
            return nil
        }
        
        self.id = id
        self.title = RedditPost.massageTitle(title: title)
        self.content = RedditContent(apiResponse: data)
        self.subreddit = subreddit
        self.previewPhoto = previewPhoto
        
        self.author = data["author"] as? String
        self.score = data["score"] as? Int
    }
    
    private static func massageTitle(title: String) -> String {
        var title = title
        if title.contains("&amp;") {
            title = title.replacingOccurrences(of: "&amp;", with: "&")
        }
        
        return title
    }
}

extension RedditPost: DisplayableFeedItem {

    var postTitle: String {
        return self.title
    }
    
    var postPhotoURL: String? {
        return previewPhoto.sourceUrl
    }
}

extension RedditPost: Readable {
    
    var text: String {
        return title
    }
}
