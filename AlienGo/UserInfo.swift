//
//  UserInfo.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/17/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit
import KeychainAccess

class UserInfo {

    static var username: String? {
        get {
            return UserDefaults.standard.string(forKey: "alienReaderUsername")
        }
        
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "alienReaderUsername")
            } else {
                UserDefaults.standard.set(newValue, forKey: "alienReaderUsername")
            }
            
            UserDefaults.standard.synchronize()
        }
    }
    
    static var utteranceSpeed: Float {
        get {
            let speed = UserDefaults.standard.float(forKey: "alienReaderUtteranceSpeed")
            
            return speed == 0 ? 0.5 : speed
        }
        
        set {
            if newValue == nil {
                UserDefaults.standard.removeObject(forKey: "alienReaderUtteranceSpeed")
            } else {
                UserDefaults.standard.set(newValue, forKey: "alienReaderUtteranceSpeed")
            }
            
            UserDefaults.standard.synchronize()
        }
    }
}

class AuthInfo {
    
    static let keychainAccessToken = "alienReaderAccessToken"
    static let keychainRefreshToken = "alienReaderRefreshToken"
    static let keychainRedditUsernameKeychain = "alienReaderRedditUsernameKeychain"
    
    static var accessToken: String? {
        get {
            return try! Keychain().get(keychainAccessToken)
        }
        
        set {
            if let newValue = newValue {
                try! Keychain().set(newValue, key: keychainAccessToken)
            } else {
                try! Keychain().remove(keychainAccessToken)
            }
        }
    }
    
    static var refreshToken: String? {
        get {
            return try! Keychain().get(keychainRefreshToken)
        }
        
        set {
            if let newValue = newValue {
                try! Keychain().set(newValue, key: keychainRefreshToken)
            } else {
                try! Keychain().remove(keychainRefreshToken)
            }
        }
    }
}
