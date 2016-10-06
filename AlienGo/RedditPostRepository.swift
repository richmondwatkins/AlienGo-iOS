//
//  RedditPostRepository.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

typealias RedditPostFetchCallback = (_ posts: [RedditPost]) -> Void

class RedditPostRepository {

    func get(callback: @escaping RedditPostFetchCallback) {
        NetworkManager.shared.getRedditPosts { (response, error) in
            guard let response = response, let postResponse = (response["data"] as? [String: AnyObject])?["children"] as? [[String: AnyObject]], error == nil else {
                print("NONE AT FIRST PAGE")
                return
            }
            
            callback(self.deserializeRedditPostResponse(response: postResponse))
        }
    }
    
    func loadMore(postId: String, totalCount: Int, callback: @escaping RedditPostFetchCallback) {
        NetworkManager.shared.getRedditPostsAtPage(lastPostId: postId, totalPostCount: totalCount) { (response, error) in
            print(response)
            guard let response = response, let postResponse = (response["data"] as? [String: AnyObject])?["children"] as? [[String: AnyObject]], error == nil else {
                print("NONE AT PAGE")
                return
            }
            
            callback(self.deserializeRedditPostResponse(response: postResponse))
        }
    }
    
    func deserializeRedditPostResponse(response: [[String: AnyObject]]) -> [RedditPost] {
        var posts: [RedditPost] = []
        
        posts.append(contentsOf: response.flatMap { (obj) in
            return RedditPost(apiResponse: obj)
        })
        
        return posts
    }
}
