//
//  SettingAutoNavAfterCommentsTableViewCell.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/29/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class SettingAutoNavAfterCommentsTableViewCell: UITableViewCell {

    @IBOutlet weak var settingTitleLabel: UILabel!
    @IBOutlet weak var settingSwitch: UISwitch!
    
    func configure(settingItem: SettingItem) {
        settingTitleLabel.text = settingItem.text
        
        settingSwitch.setOn(UserAppState.autoNavAfterComments, animated: false)
    }
    
    @IBAction func didSwitch(_ sender: UISwitch) {
        UserAppState.autoNavAfterComments = sender.isOn
    }
    
}
