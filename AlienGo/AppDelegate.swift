//
//  AppDelegate.swift
//  AlienGo
//
//  Created by Richmond Watkins on 10/4/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import Fabric
import Crashlytics
import KeychainAccess
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let subredditRepository = SubredditRepository()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = AppDelegateConfigurator.setup()
        
        subredditRepository.storeSubscriptions()
        
        return true
    }
    
    func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
        }
    }


    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.absoluteString.contains("oauth") {
            let components: NSURLComponents = NSURLComponents(string: url.absoluteString)!
            if let code = components.queryItems?.filter({$0.name == "code"}).first?.value {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationAuthCodeReceived), object: nil, userInfo: ["code": code])
            }
        }
        
        return true
    }
}

