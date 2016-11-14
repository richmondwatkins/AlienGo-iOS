//
//  RedditPost.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

struct NewsPost {

    let subreddit: Category
    let previewPhoto: PreviewPhoto
    var content: RedditContent
    let id: String
    let name: String
    let title: String
    let permalink: String
    var author: String?
    var score: Int?
    var readCompletionHandler: (() -> Void)?
    
    init?(apiResponse: [String: AnyObject]) {
        guard let data = apiResponse["data"] as? [String: AnyObject],
            let subreddit = Category(apiResponse: data),
            let id = data["id"] as? String,
            let previewPhoto = PreviewPhoto(apiResponse: data),
            let name = data["name"] as? String,
            let permalink: String = data["permalink"] as? String,
            let title = data["title"] as? String else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.title = NewsPost.massageTitle(title: title)
        self.content = RedditContent(apiResponse: data)
        self.subreddit = subreddit
        self.previewPhoto = previewPhoto
        self.permalink = permalink
        
        self.author = data["author"] as? String
        self.score = data["score"] as? Int
    }
    
    private static func massageTitle(title: String) -> String {
        var title = title
        if title.contains("&amp;") {
            title = title.replacingOccurrences(of: "&amp;", with: "&")
        }
        
        if title.contains("TIL") {
            title = title.replacingOccurrences(of: "TIL", with: "Today I Learned")
        }
        
        if title.contains("MRW") {
            title = title.replacingOccurrences(of: "MRW", with: "My Reaction When")
        }
        
        return title
    }
}

extension NewsPost: DisplayableFeedItem {
    var postedByUsername: String? {
        return author
    }

    var postSubredditName: String? {
        return "/r/\(subreddit.name)"
    }

    internal var postPermalink: String {
        return permalink
    }

    var postId: String {
        return id
    }

    var postName: String {
        return name
    }

    var postTitle: String {
        return self.title
    }
    
    var postPhotoURL: String? {
        return previewPhoto.sourceUrl
    }
}

extension NewsPost: Readable {
    
    var text: String {
        return title
    }
}
