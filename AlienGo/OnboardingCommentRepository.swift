//
//  OnboardingCommentRepository.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/10/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class OnboardingCommentRepository: CommentRepository {
    
    
    func get(detailPostItem: DetailPostItem, callback: @escaping CommentFetchCallback) {
        if let filePath = Bundle.main.path(forResource: "onboardingComments", ofType: "json"), let data = NSData(contentsOfFile: filePath) {
            do {
                let response = try JSONSerialization.jsonObject(with: data as Data, options: JSONSerialization.ReadingOptions.allowFragments) as! [AnyObject]
                
                guard response.count == 2,
                    let comments = (response[1] as? [String: AnyObject])?["data"]?["children"] as? [[String: AnyObject]] else {
                        callback(nil, nil, nil)
                        return
                }
                
                let deserializedComments = comments.flatMap({ (apiComment) -> Comment? in
                    return Comment(apiResponse: apiComment, postAuthor: nil)
                })
                
                let singleLevelComment = self.buildSingleLevelComments(comments: deserializedComments)
                
                callback(singleLevelComment, deserializedComments, nil)
            }
            catch {
                print(error)
            }
        }
    }
}
