//
//  Subreddit.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

func ==(lhs: Category, rhs: Category) -> Bool {
    return lhs.name == rhs.name
}

struct Category: Equatable {

    let name: String
    private var subscribed: Bool = false
    
    var urlPath: String {
        if name == "front" {
            if let _ = AuthInfo.accessToken, let _ = AuthInfo.refreshToken {
                return "/"
            }
            
            return "/.json"
        }
        
        if let _ = AuthInfo.accessToken, let _ = AuthInfo.refreshToken {
            return "/r/\(name)"
        }
        
        return "/r/\(name).json"
    }
    
    init?(apiResponse: [String: AnyObject]) {
        guard let name = apiResponse["subreddit"] as? String else {
            return nil
        }
        
        self.name = name
    }
    
    init?(nytApiResponse: [String: AnyObject]) {
        guard let name = nytApiResponse["section"] as? String else {
            return nil
        }
        
        self.name = name
    }
    
    
    init(name: String) {
        self.name = name
    }
    
    mutating func setSubscribed(subscribed: Bool) {
        self.subscribed = subscribed
    }
    
    func getSubscribed() -> Bool {
        return self.subscribed
    }
}
