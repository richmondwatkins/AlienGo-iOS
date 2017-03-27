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
        var retSettings: [SettingItem] = [
            SettingSpeechSpeed(),
            SettingAutoPlayItem(),
            SettingAutoNavBack()
        ];
        
        SubscribedCategoryRepository().get()
            .map({ NYTSubscription(name: $0.name, iconURL: nil) })
            .flatMap({ SettingSubscribedCategory(subscription: $0) })
            .forEach { (subscription) in
                retSettings.append(subscription)
        }

        return retSettings
    }
}

struct NYTSubscription: Subscription {
    var name: String?
    var iconURL: String?
}
