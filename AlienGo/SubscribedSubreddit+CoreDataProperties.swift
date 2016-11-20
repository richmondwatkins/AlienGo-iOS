//
//  SubscribedSubreddit+CoreDataProperties.swift
//  
//
//  Created by Richmond Watkins on 11/19/16.
//
//

import Foundation
import CoreData


extension SubscribedSubreddit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SubscribedSubreddit> {
        return NSFetchRequest<SubscribedSubreddit>(entityName: "SubscribedSubreddit");
    }
    @NSManaged public var name: String?
    @NSManaged public var iconURL: String?

}

extension SubscribedSubreddit: ManagedObjectType {
    static var entityName: String { return "SubscribedSubreddit" }
}

protocol ManagedObjectType {
    static var entityName: String { get }
}
