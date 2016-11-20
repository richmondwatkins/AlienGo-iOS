//
//  CommentRepository.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/6/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

typealias CommentFetchCallback = (_ linearComments: [Comment]?, _ orderedComments: [Comment]?, _ error: Error?) -> Void

protocol CommentRepository {
    func get(detailPostItem: DetailPostItem, callback: @escaping CommentFetchCallback)
    func buildSingleLevelComments(comments: [Comment]) -> [Comment]
}

extension CommentRepository {
    
    func buildSingleLevelComments(comments: [Comment]) -> [Comment] {
        var retVal: [Comment] = []
        
        comments.forEach { (comment) in
            retVal.append(comment)
            if comment.replies.count > 0 {
                retVal.append(contentsOf: buildSingleLevelComments(comments: comment.replies))
            }
        }
        
        return retVal
    }
}

class MainCommentRepository: CommentRepository {

    
    func get(detailPostItem: DetailPostItem, callback: @escaping CommentFetchCallback) {
        NetworkManager.shared.getCommentsForPost(permalink: detailPostItem.permalink) { (response, error) in
            guard let response = response as? [AnyObject], response.count == 2,
                let comments = (response[1] as? [String: AnyObject])?["data"]?["children"] as? [[String: AnyObject]] else {
                    callback(nil, nil, error)
                return
            }
            
            let deserializedComments = comments.flatMap({ (apiComment) -> Comment? in
                return Comment(apiResponse: apiComment, postAuthor: detailPostItem.author)
            })
            
            let singleLevelComment = self.buildSingleLevelComments(comments: deserializedComments)
            
            callback(singleLevelComment, deserializedComments, nil)
        }
    }
}
