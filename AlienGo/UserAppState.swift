//
//  UserAppState.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/22/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class UserAppState {

    static var hasSeenOnboarding: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "alienReaderHasSeenOnboarding")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "alienReaderHasSeenOnboarding")
            UserDefaults.standard.synchronize()
        }
    }
    
    static var shouldStartReading: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "shouldStartReading")
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "shouldStartReading")
            UserDefaults.standard.synchronize()
        }
    }
}
