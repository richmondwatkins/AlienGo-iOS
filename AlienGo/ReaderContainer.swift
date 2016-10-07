//
//  ReaderContainer.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/5/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

struct ReaderContainer: Readable {
    var text: String
    var readCompletionHandler: (() -> Void)?
    
    init(text: String) {
        self.text = text
    }
    
    init(readable: Readable) {
        self.text = readable.text
    }
}
