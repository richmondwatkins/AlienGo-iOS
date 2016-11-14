//
//  RedditPostProvider.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit


class RedditPostProvider {
    
    let repository: NewsPostRepository

    init(repository: NewsPostRepository) {
        self.repository = repository
    }
    
    func getPostsFor(subreddit: Category) -> [NewsPost] {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        var posts: [NewsPost] = [NewsPost]()
        
        repository.getPostsFor(subreddit: subreddit) { (redditPosts) in
            posts = redditPosts
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return posts
    }
    
    func loadMore(postId: String, totalCount: Int) -> [NewsPost] {
        let semaphore: DispatchSemaphore = DispatchSemaphore(value: 0)
        var posts: [NewsPost] = [NewsPost]()
        
        repository.loadMore(postId: postId, totalCount: totalCount) { (redditPosts) in
            posts = redditPosts
            
            semaphore.signal()
        }
        
        semaphore.wait()
        
        return posts
    }
}
