//
//  SettingAuthItem.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/16/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit
import KeychainAccess

struct SettingAuthItem: SettingItem {
    var type: SettingType
    var text: String

    init() {
        if let username = UserInfo.username {
            type = .postAuth
            text = username
        } else {
            text = "Add your account"
            type = .preAuth
        }
    }
    
    func configure(tableView: UITableView) -> UITableViewCell {
        if type == .preAuth {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: RASettingsSignInTableViewCell.self)) as! RASettingsSignInTableViewCell
            
            cell.accessoryType = .disclosureIndicator
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AccountInfoTableViewCell.self)) as! AccountInfoTableViewCell
                        
            return cell
        }
    }
    
    func didSelect(currentVC: UIViewController, actionDelegate: ActionDelegate) -> UIViewController? {
//        if type == .preAuth {
            return UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: String(describing: RAAuthWebViewController.self))
//        } else {
//            
//        }
    }
}
