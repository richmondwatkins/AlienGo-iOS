//
//  SettingAutoNavBack.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/29/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class SettingAutoNavBack: SettingItem {
    
    let type: SettingType
    let text: String
    
    init() {        
        type = .autoNavBack
        text = Configuration.settingsAutoNavText
    }
    
    func configure(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SettingAutoNavAfterCommentsTableViewCell.self)) as! SettingAutoNavAfterCommentsTableViewCell
        
        cell.configure(settingItem: self)
        
        return cell
    }
    
    func didSelect(currentVC: UIViewController, actionDelegate: ActionDelegate) -> UIViewController? {
       
        
        return nil
    }
}
