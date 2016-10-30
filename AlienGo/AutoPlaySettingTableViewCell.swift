//
//  AutoPlaySettingTableViewCell.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/30/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

class AutoPlaySettingTableViewCell: UITableViewCell {

    @IBOutlet weak var settingTitleLabel: UILabel!
    @IBOutlet weak var autoPlaySwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        autoPlaySwitch.setOn(StateProvider.isAuto, animated: false)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func didChangeSwitchVal(_ sender: UISwitch) {
        StateProvider.isAuto = sender.isOn
    }
}
