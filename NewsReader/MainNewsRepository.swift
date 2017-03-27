//
//  MainNewsRepository.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/13/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit
import Alamofire

class MainNewsRepository: NewsPostRepository {
    
    let catogoryRepo: SubscribedCategoryRepository = SubscribedCategoryRepository()
    
    func getPostsFor(subreddit: Category, callback: @escaping NewsPostFetchCallback) {
        DispatchQueue.global(qos: .default).async {
            let categories = self.catogoryRepo.get()
            //https://api.nytimes.com/svc/topstories/v2/upshot.json
            
            var apiResponses: [[String: AnyObject]] = []
            
            let operations = categories.map({ (category) -> NYTRequestOperation in
                return NYTRequestOperation(category: category, callback: { (result, success) in
                    if let result = result, let results = result["results"] as? [[String: AnyObject]], success {
                        apiResponses.append(contentsOf: results)
                    }
                })
            })
            
            let queue = OperationQueue()
            queue.maxConcurrentOperationCount = 20
            
            queue.addOperations(operations, waitUntilFinished: true)
            
            let newsPosts = apiResponses.flatMap({ (response) -> NewsPost? in
                return NewsPost(nytApiResponse: response)
            }).sorted(by: { (post1, post2) -> Bool in
                return post1.postedDate > post2.postedDate
            })
            
            callback(newsPosts)
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
