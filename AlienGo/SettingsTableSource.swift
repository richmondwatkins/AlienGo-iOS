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
    var vc: UIViewController { get }
    var actionDelegate: ActionDelegate { get }
}

class SettingsTableSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    var dataSource: [SettingItem] = SettingBuilder.build()
    var displayDelegate: SettingsDisplayDelegate!
    
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = self
            tableView.delegate = self
            tableView.rowHeight = UITableViewAutomaticDimension
            tableView.estimatedRowHeight = 100
        
            regsiterCells(cellStrings: [
                String(describing: RASettingsSignInTableViewCell.self),
                String(describing: AccountInfoTableViewCell.self),
                String(describing: AllFrontSettingTableViewCell.self),
                String(describing: SpeechVolumeCellTableViewCell.self)
            ])
        }
    }
    
    func regsiterCells(cellStrings: [String]) {
        cellStrings.forEach { (cellString) in
            tableView.register(UINib(nibName: cellString, bundle: Bundle.main), forCellReuseIdentifier: cellString)
        }
    }
    
    func refresh() {
        dataSource = SettingBuilder.build()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let dataItem = dataSource[indexPath.row]
        
        return dataItem.type == .postAuth
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (dataSource[indexPath.row].type == .postAuth) {
            UserInfo.username = nil
            AuthInfo.accessToken = nil
            AuthInfo.refreshToken = nil
            dataSource[indexPath.row] = SettingAuthItem()
            tableView.reloadData()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dataItem = dataSource[indexPath.row]

        return dataItem.configure(tableView: tableView)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = dataSource[indexPath.row].didSelect(currentVC: displayDelegate.vc, actionDelegate: displayDelegate.actionDelegate) {
            displayDelegate.display(vc: vc)
        }
    }
}
