//
//  Readable.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol Readable {
    var text: String { get }
    var readCompletionHandler: (() -> Void)? { get set }
}
