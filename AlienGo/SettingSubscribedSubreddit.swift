//
//  SettingSubscribedSubreddit.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/19/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit
import CoreData

class SettingSubscribedSubreddit: SettingItem {
    
    let type: SettingType
    let text: String
    var iconURL: String?
    
    init?(subscribedSubreddit: SubscribedSubreddit) {
        guard let name = subscribedSubreddit.name else { return nil }
        
        type = .subreddit
        text = name
        iconURL = subscribedSubreddit.iconURL
    }
    
    func configure(tableView: UITableView) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: SubscribedSubredditTableViewCell.self)) as! SubscribedSubredditTableViewCell
        
        cell.configure(subreddit: self)
        
        return cell
    }
    
    func didSelect(currentVC: UIViewController, actionDelegate: ActionDelegate) -> UIViewController? {
        actionDelegate.show(subreddit: Category(name: text))
        
        DispatchQueue.main.async {
            currentVC.dismiss(animated: true, completion: nil)
        }
        
        return nil
    }
}
