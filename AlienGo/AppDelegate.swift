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
        
        Fabric.with([Crashlytics.self])
        
        var navId: String = "MainViewControllerNavigationController"
        var storyboard: String = "Main"
        
        if !UserAppState.hasSeenOnboarding {
            navId = "OnboardingNavigationController"
            storyboard = "Onboarding"
        }

        subredditRepository.storeSubscriptions()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = UIStoryboard(name: storyboard, bundle: Bundle.main).instantiateViewController(withIdentifier: navId)
        window?.makeKeyAndVisible()
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
        catch let error as NSError {
            print("Error: Could not set audio category: \(error), \(error.userInfo)")
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        }
        catch let error as NSError {
            print("Error: Could not setActive to true: \(error), \(error.userInfo)")
        }
        
        
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

