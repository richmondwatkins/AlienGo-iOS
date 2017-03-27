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
    var content: RedditContent
    let id: String
    let title: String
    let permalink: String
    let name: String
    var author: User?
    var score: Int?
    var readCompletionHandler: (() -> Void)?
    var postedDate: Date = Date()
    
    init?(apiResponse: [String: AnyObject]) {
        guard let data = apiResponse["data"] as? [String: AnyObject],
            let subreddit = Category(apiResponse: data),
            let id = data["id"] as? String,
            let permalink: String = data["permalink"] as? String,
            let name = data["name"] as? String,
            let title = data["title"] as? String else {
            return nil
        }
        
        self.id = id
        self.name = name
        self.title = NewsPost.massageTitle(title: title)
        self.content = RedditContent(apiResponse: data)
        self.subreddit = subreddit
        self.permalink = permalink
        
        if let auther = data["author"] as? String {
            self.author = User(username: auther)
        }
        
        self.score = data["score"] as? Int
    }
    
    init?(nytApiResponse: [String: AnyObject]) {
        guard let category = Category(nytApiResponse: nytApiResponse),
            let id = nytApiResponse["url"] as? String,
            let permalink: String = nytApiResponse["url"] as? String,
            let content = RedditContent(nytApiResponse: nytApiResponse),
            let title = nytApiResponse["title"] as? String else {
                return nil
        }
        
        self.id = id
        self.title = NewsPost.massageTitle(title: title)
        self.content = content
        self.subreddit = category
        self.permalink = permalink
        self.name = title
        
        if let publishedDate = nytApiResponse["published_date"] as? String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            self.postedDate = dateFormatter.date(from: publishedDate)!
        }
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
        return author?.username
    }

    var postSubredditName: String? {
        return "\(subreddit.name)"
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
}

extension NewsPost: Readable {
    
    var text: String {
        return title
    }
}
