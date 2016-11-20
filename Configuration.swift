//
//  Configuration.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/13/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class Configuration {

    static var readableName: String {
       return plistDict()["ReadableName"] as! String
    }
    
    static var onboardingOpeningText: String {
        return plistDict()["OnboardingOpening"] as! String
    }
    
    static var onboardingCompleteText: String {
        return plistDict()["OnboardingCompleteText"] as! String
    }
    
    static var showCategorySelection: Bool {
        return plistDict()["ShowCategorySelection"] as! Bool
    }
    
    static var commentsEnabled: Bool {
        return plistDict()["CommentsEnabled"] as! Bool
    }
    
    static var onboardingDetailText: String {
        return plistDict()["OnboardingDetailExplanation"] as! String
    }
    
    static func plistDict() -> NSDictionary {
        return NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Info", ofType: "plist")!)!["AppConfig"] as! NSDictionary
    }
    
    static var cdModelName: String {
        return plistDict()["CoreDataModelName"] as! String
    }
}
