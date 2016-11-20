//
//  SubredditRepository.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/19/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit
import CoreData

class SubredditRepository {

    func storeSubscriptions() {
        NetworkManager.shared.getDefaultSubreddits { (subResponse, error) in
            guard let subreddits = subResponse,
                let defaults = (subreddits["data"] as? [String: AnyObject])?["children"] as? [[String: AnyObject]],
                defaults.count > 0 else { return }
            
            CoreDataManager.shared.deleteAll(entityName: SubscribedSubreddit.entityName)
            
            defaults.forEach({ (sub) in
                guard let data = sub["data"] as? [String: AnyObject], let name = data["url"] as? String else { return }
                
                let entity = NSEntityDescription.insertNewObject(forEntityName: SubscribedSubreddit.entityName, into: CoreDataManager.shared.managedObjectContext) as! SubscribedSubreddit
                entity.name = name.replacingOccurrences(of: "/r/", with: "").replacingOccurrences(of: "/", with: "")
                entity.iconURL = data["icon_img"] as? String
            })
            
            CoreDataManager.shared.saveContext()
        }
    }
    
    func get() -> [SubscribedSubreddit] {
        var subs = [SubscribedSubreddit]()
        
        let fetchRequest = NSFetchRequest<SubscribedSubreddit>(entityName: SubscribedSubreddit.entityName)
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        if let cdSubs = try? CoreDataManager.shared.managedObjectContext.fetch(fetchRequest) {
            subs = cdSubs
        }
        
        return subs
    }
}
