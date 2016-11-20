//
//  Comment.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/6/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

func ==<T: CommentItem>(lhs: T, rhs: T) -> Bool {
    return lhs.id == rhs.id
}

protocol CommentItem: Equatable {
    var id: String { get }
    var parent: Comment? { get }
}

class Comment: CommentItem {
    var id: String
    let score: Int
    let body: String
    let nestedLevel: Int
    var user: User
    var replies: [Comment] = []
    var parent: Comment?
    
    init?(apiResponse: [String: AnyObject], postAuthor: User?, nestedLevel: Int = 0, parent: Comment? = nil) {
        guard let data = apiResponse["data"] as? [String: AnyObject],
            let id = data["id"] as? String,
            let score = data["score"] as? Int,
            let username = data["author"] as? String,
            let body = data["body"] as? String else {
            return nil
        }
        
        self.id = id
        self.user = User(username: username)
        self.score = score
        self.body = body.replacingOccurrences(of: "&gt;", with: "\"")
        self.nestedLevel = nestedLevel
        self.parent = parent
        
        if self.user == postAuthor {
            self.user.isOp = true
        }
        
        if let replies = (data["replies"]?["data"] as? [String: AnyObject])?["children"] as? [[String: AnyObject]] {
            for reply in replies {
                if let comment = Comment(apiResponse: reply, postAuthor: postAuthor, nestedLevel: nestedLevel + 1, parent: self) {
                    self.replies.append(comment)
                }
            }
        }
    }
}

extension Comment: Readable {
    var text: String {
        return body
    }
}
