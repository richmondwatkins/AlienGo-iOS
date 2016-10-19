//
//  AccountInfoTableViewCell.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/17/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit
import KeychainAccess

class AccountInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let username = UserInfo.username {
            usernameLabel.text = username
        }
    }
}
