//
//  RedditPostRepository.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/13/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

typealias NewsPostFetchCallback = (_ posts: [NewsPost]) -> Void

protocol NewsPostRepository {
    func getPostsFor(subreddit: Subreddit, callback: @escaping NewsPostFetchCallback)
    func loadMore(postId: String, totalCount: Int, callback: @escaping NewsPostFetchCallback)
    func deserializeRedditPostResponse(response: [[String: AnyObject]]) -> [NewsPost]
}

extension NewsPostRepository {
    
    func deserializeRedditPostResponse(response: [[String: AnyObject]]) -> [NewsPost] {
        var posts: [NewsPost] = []
        
        posts.append(contentsOf: response.flatMap { (obj) in
            return NewsPost(apiResponse: obj)
        })
        
        return posts
    }
}
