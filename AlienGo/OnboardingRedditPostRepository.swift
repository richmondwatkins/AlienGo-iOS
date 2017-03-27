//
//  OnboardingRedditPostRepository.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/10/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class OnboardingRedditPostRepository: NewsPostRepository {
    
    func getPostsFor(subreddit: Category, callback: @escaping NewsPostFetchCallback) {
        if let filePath = Bundle.main.path(forResource: "allSeed", ofType: "json"), let data = NSData(contentsOfFile: filePath) {
            do {
                let response = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                
                guard let postResponse = (response["data"] as? [String: AnyObject])?["children"] as? [[String: AnyObject]] else {
                    return
                }
                
                callback(self.deserializeRedditPostResponse(response: postResponse))
            }
            catch {
                print(error)
            }
        }
    }

    func loadMore(postId: String, totalCount: Int, callback: @escaping NewsPostFetchCallback) {
        NetworkManager.shared.getRedditPostsAtPage(lastPostId: postId, totalPostCount: totalCount) { (response, error) in
            guard let response = response, let postResponse = (response["data"] as? [String: AnyObject])?["children"] as? [[String: AnyObject]], error == nil else {
                print("NONE AT PAGE")
                return
            }
            
            callback(self.deserializeRedditPostResponse(response: postResponse))
        }
    }
}
