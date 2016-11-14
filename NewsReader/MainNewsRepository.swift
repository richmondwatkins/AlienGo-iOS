//
//  MainNewsRepository.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/13/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class MainNewsRepository: NewsPostRepository {
    
    func getPostsFor(subreddit: Category, callback: @escaping NewsPostFetchCallback) {
        NetworkManager.shared.getPostsForSubreddit(subreddit: subreddit) { (response, error) in
            guard let response = response, let postResponse = (response["data"] as? [String: AnyObject])?["children"] as? [[String: AnyObject]], error == nil else {
                print("NONE AT FIRST PAGE")
                return
            }
            
            callback(self.deserializeRedditPostResponse(response: postResponse))
        }
    }
    
    func loadMore(postId: String, totalCount: Int, callback: @escaping NewsPostFetchCallback) {
        NetworkManager.shared.getRedditPostsAtPage(lastPostId: postId, totalPostCount: totalCount) { (response, error) in
            print(response)
            guard let response = response, let postResponse = (response["data"] as? [String: AnyObject])?["children"] as? [[String: AnyObject]], error == nil else {
                print("NONE AT PAGE")
                return
            }
            
            callback(self.deserializeRedditPostResponse(response: postResponse))
        }
    }
}
