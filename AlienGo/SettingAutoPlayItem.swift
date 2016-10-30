//
//  SettingAutoPlayItem.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/30/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class SettingAutoPlayItem: SettingItem {
    
    var type: SettingType
    var text: String
    
    init() {
        type = .auto
        text = "Auto Play"
    }
    
    func configure(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AutoPlaySettingTableViewCell.self)) as! AutoPlaySettingTableViewCell
        
        cell.settingTitleLabel.text = text
        
        return cell
    }
    
    func didSelect(currentVC: UIViewController, actionDelegate: ActionDelegate) -> UIViewController? {

        return nil
    }
}

