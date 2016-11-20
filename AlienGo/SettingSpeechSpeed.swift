//
//  SettingSpeechSpeed.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/19/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class SettingSpeechSpeed: SettingItem {
    
    var type: SettingType
    var text: String
    
    init() {
        type = .speedControl
        text = "Speed Control"
    }
    
    func configure(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SpeechVolumeCellTableViewCell.self)) as! SpeechVolumeCellTableViewCell
        
        return cell
    }
    
    func didSelect(currentVC: UIViewController, actionDelegate: ActionDelegate) -> UIViewController? {
        
        actionDelegate.showAll()
        
        DispatchQueue.main.async {
            currentVC.dismiss(animated: true, completion: nil)
        }
        
        return nil
    }
}
