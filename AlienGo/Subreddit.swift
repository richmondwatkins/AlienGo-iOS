//
//  Subreddit.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

func ==(lhs: Subreddit, rhs: Subreddit) -> Bool {
    return lhs.name == rhs.name
}

struct Subreddit: Equatable {

    let name: String
    
    var urlPath: String {
        if name == "front" {
            return "/"
        }
        
        return "/r/\(name)"
    }
    
    init?(apiResponse: [String: AnyObject]) {
        guard let name = apiResponse["subreddit"] as? String else {
            return nil
        }
        
        self.name = name
    }
    
    init(name: String) {
        self.name = name
    }
}
