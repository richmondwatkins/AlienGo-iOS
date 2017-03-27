//
//  StateProvider.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/10/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class StateProvider {

    static var isAuto: Bool {
        get {
           return UserDefaults.standard.bool(forKey: "isAuto")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "isAuto")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var hasSeenNewAutoNavSetting: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "hasSeenNewAutoNavSetting")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "hasSeenNewAutoNavSetting")
            UserDefaults.standard.synchronize()
        }
    }
}
