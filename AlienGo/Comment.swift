//
//  Comment.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/6/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

struct Comment {
    let id: String
    let score: Int
    let body: String
    let nestedLevel: Int
    var replies: [Comment] = []
    
    init?(apiResponse: [String: AnyObject], nestedLevel: Int = 0) {
        guard let data = apiResponse["data"] as? [String: AnyObject],
            let id = data["id"] as? String,
            let score = data["score"] as? Int,
            let body = data["body"] as? String else {
            return nil
        }
        
        self.id = id
        self.score = score
        self.body = body
        self.nestedLevel = nestedLevel
        
        if let replies = (data["replies"]?["data"] as? [String: AnyObject])?["children"] as? [[String: AnyObject]] {
            for reply in replies {
                if let comment = Comment(apiResponse: reply, nestedLevel: nestedLevel + 1) {
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
