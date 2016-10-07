//
//  User.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/6/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

struct User: Readable {
    let username: String
    var readCompletionHandler: (() -> Void)?
    
    var text: String {
        return username
    }
    
    init(username: String) {
        self.username = username
    }
}
