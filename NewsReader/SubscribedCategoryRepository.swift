//
//  SubscribedCategoryRepository.swift
//  Alien Reader
//
//  Created by Richmond Watkins on 11/14/16.
//  Copyright © 2016 Nashville Native. All rights reserved.
//

import UIKit
import CoreData

struct SubscribedCategoryRepository {

    func get(completion: @escaping ([Category]) -> Void) {
        CoreDataManager.shared.perform {
            let fetchRequest:NSFetchRequest<SubscribedCategory> = SubscribedCategory.fetchRequest()
            
            if let categories = try? CoreDataManager.shared.managedObjectContext.fetch(fetchRequest) {
                completion(categories.flatMap({ (subCat) -> Category? in
                    guard let name = subCat.name else { return nil }
                    
                    return Category(name: name)
                }))
            }
        }
    }
    
    func set(categories: [Category]) {
        CoreDataManager.shared.perform {
            categories.forEach({ (category) in
                let request = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: "SubscribedCategory"))
                _ = try? CoreDataManager.shared.managedObjectContext.execute(request)
                
                let subCategory: SubscribedCategory = NSEntityDescription.insertNewObject(forEntityName: "SubscribedCategory", into: CoreDataManager.shared.managedObjectContext) as! SubscribedCategory
                subCategory.name = category.name
                
                CoreDataManager.shared.managedObjectContext.insert(subCategory)
            })
            
            CoreDataManager.shared.saveContext()
        }
    }
}
