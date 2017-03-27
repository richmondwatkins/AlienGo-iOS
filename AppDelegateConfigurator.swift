//
//  AppDelegateConfigurator.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/30/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit
import AVFoundation
import Fabric
import Crashlytics
import KeychainAccess

class AppDelegateConfigurator {

    static func setup() -> UIWindow {
        Fabric.with([Crashlytics.self])
        
        var navId: String = "MainViewControllerNavigationController"
        var storyboard: String = "Main"
        
        if !UserAppState.hasSeenOnboarding {
            navId = "OnboardingNavigationController"
            storyboard = "Onboarding"
        }
        
        
        if !StateProvider.hasSeenNewAutoNavSetting {
            UserAppState.autoNavAfterComments = true
            StateProvider.hasSeenNewAutoNavSetting = true
        }
        
        UINavigationBar.appearance().tintColor = UIColor(ColorConstants.appBlue)
        
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.rootViewController = UIStoryboard(name: storyboard, bundle: Bundle.main).instantiateViewController(withIdentifier: navId)
        window.makeKeyAndVisible()
        
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
        
        return window
    }
}
