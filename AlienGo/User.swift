//
//  User.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/6/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.username == rhs.username
}

struct User: Readable, Equatable {
    let username: String
    var isOp: Bool = false
    
    var text: String {
        return username
    }
    
    init(username: String) {
        self.username = username
    }
}
