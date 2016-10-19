//
//  SettingsTableSource.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 10/16/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit

protocol SettingsDisplayDelegate {
    func display(vc: UIViewController)
}

class SettingsTableSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var dataSource: [SettingItem] = SettingBuilder.build()
    var displayDelegate: SettingsDisplayDelegate?
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            let signInCell: String = String(describing: RASettingsSignInTableViewCell.self)
            tableView.register(UINib(nibName: signInCell, bundle: Bundle.main), forCellReuseIdentifier: signInCell)
            
            let accountCell: String = String(describing: AccountInfoTableViewCell.self)
            tableView.register(UINib(nibName: accountCell, bundle: Bundle.main), forCellReuseIdentifier: accountCell)
        }
    }
    
    func refresh() {
        dataSource = SettingBuilder.build()
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataItem = dataSource[indexPath.row]

        return dataItem.configure(tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        displayDelegate?.display(vc: dataSource[indexPath.row].didSelect())
    }
}
