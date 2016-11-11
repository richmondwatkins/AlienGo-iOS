//
//  OnboardingRedditPostRepository.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/10/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class OnboardingRedditPostRepository: RedditPostRepository {
    
    func getPostsFor(subreddit: Subreddit, callback: @escaping RedditPostFetchCallback) {
        if let filePath = Bundle.main.path(forResource: "allSeed", ofType: "json"), let data = NSData(contentsOfFile: filePath) {
            do {
                let response = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                
                guard let postResponse = (response["data"] as? [String: AnyObject])?["children"] as? [[String: AnyObject]] else {
                    print("NONE AT FIRST PAGE")
                    return
                }
                
                callback(self.deserializeRedditPostResponse(response: postResponse))
            }
            catch {
                print(error)
            }
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
}
