//
//  SubscribedCategory+CoreDataProperties.swift
//  
//
//  Created by Richmond Watkins on 11/14/16.
//
//

import Foundation
import CoreData


extension SubscribedCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubscribedCategory> {
        return NSFetchRequest<SubscribedCategory>(entityName: "SubscribedCategory");
    }

    @NSManaged public var name: String?

}
