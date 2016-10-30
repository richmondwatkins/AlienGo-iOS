//
//  SettingFrontPageItem.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/19/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

struct SettingFrontPageItem: SettingItem {
   
    var type: SettingType
    var text: String
    
    init() {
        type = .front
        text = "Front"
    }

    func configure(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: AllFrontSettingTableViewCell.self)) as! AllFrontSettingTableViewCell
        
        cell.titlelabel.text = text
        
        return cell
    }

    func didSelect(currentVC: UIViewController, actionDelegate: ActionDelegate) -> UIViewController? {
        
        actionDelegate.showFrontPage()
        currentVC.dismiss(animated: true, completion: nil)
        
        return nil
    }
}
