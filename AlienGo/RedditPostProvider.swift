//
//  RedditPostProvider.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit


class RedditPostProvider {
    
    lazy var repository: RedditPostRepository = RedditPostRepository()

    
    func getPostsFor(subreddit: Subreddit) -> [RedditPost] {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        var posts: [RedditPost] = [RedditPost]()
        
        repository.getPostsFor(subreddit: subreddit) { (redditPosts) in
            posts = redditPosts
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return posts
    }
    
    func loadMore(postId: String, totalCount: Int) -> [RedditPost] {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        var posts: [RedditPost] = [RedditPost]()
        
        repository.loadMore(postId: postId, totalCount: totalCount) { (redditPosts) in
            posts = redditPosts
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return posts
    }
}
