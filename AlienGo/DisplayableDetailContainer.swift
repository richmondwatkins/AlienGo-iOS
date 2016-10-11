//
//  DisplayableDetailContainer.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

struct DetailTextContainer: DetailTextItem {
    var title: String
    var content: String
    
    init?(title: String?, content: String?) {
        guard let content = content else {
            return nil
        }
        
        self.title = title ?? ""
        self.content = content
    }
}
