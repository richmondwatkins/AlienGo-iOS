//
//  SettingItem.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/16/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

enum SettingType {
    case preAuth, postAuth, auto
}

protocol SettingItem {
    var text: String { get }
    var type: SettingType { get }
    func configure(tableView: UITableView) -> UITableViewCell
    func didSelect() -> UIViewController
}

struct SettingBuilder {
   
    static func build() -> [SettingItem] {
        return [
            SettingAuthItem()
        ]
    }
}
