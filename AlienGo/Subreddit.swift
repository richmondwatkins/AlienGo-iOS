//
//  Subreddit.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

struct Subreddit {

    let name: String
    
    init?(apiResponse: [String: AnyObject]) {
        guard let name = apiResponse["subreddit"] as? String else {
            return nil
        }
        
        self.name = name
    }
}
