//
//  AppDelegate.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/30/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = AppDelegateConfigurator.setup()
                
        return true
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
