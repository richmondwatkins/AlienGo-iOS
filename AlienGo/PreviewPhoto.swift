//
//  PreviewPhoto.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

struct PreviewPhoto {

    let sourceUrl: String
    
    init?(apiResponse: [String: AnyObject]) {
        guard let sourceUrl = apiResponse["thumbnail"] as? String else {
            return nil
        }
        
        self.sourceUrl = sourceUrl
    }
}
