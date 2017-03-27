//
//  SettingBuilder.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/30/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

struct SettingBuilder {
    
    static func build() -> [SettingItem] {
        var subs: [SettingItem] = [
            SettingAllSubredditItem(),
            SettingFrontPageItem(),
            SettingAuthItem(),
            SettingSpeechSpeed(),
            SettingAutoPlayItem(),
            SettingAutoNavBack()
        ]
        
        SubredditRepository().get()
            .flatMap({ SettingSubscribedCategory(subscription: $0) })
            .forEach { (subSetting) in
                subs.append(subSetting)
        }
        
        return subs
    }
}
