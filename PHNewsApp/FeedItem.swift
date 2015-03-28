//
//  FeedItem.swift
//  Pods
//
//  Created by Pinuno Fuentes on 3/27/15.
//
//

import Foundation
import CoreData

struct FeedItemEntity {
    static let entityName = "FeedItem"
}

class FeedItem: NSManagedObject {
    @NSManaged var source : String
    @NSManaged var timeStamp: NSDate
    @NSManaged var identifier: String
    @NSManaged var title: String
    @NSManaged var link: String
    @NSManaged var author: String
    @NSManaged var date: NSDate
    @NSManaged var summary: String
    @NSManaged var content: String
    @NSManaged var enclosures: String
    @NSManaged var updatedDate: NSDate

}
