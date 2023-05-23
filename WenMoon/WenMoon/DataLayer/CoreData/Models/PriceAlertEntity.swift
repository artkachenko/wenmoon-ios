//
//  PriceAlertEntity.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 23.05.23.
//
//

import Foundation
import CoreData

@objc(PriceAlertEntity)
final class PriceAlertEntity: NSManagedObject {

    @nonobjc class func fetchRequest(sortDescriptors: [NSSortDescriptor] = [],
                                     predicate: NSPredicate? = nil) -> NSFetchRequest<PriceAlertEntity> {
        let request = NSFetchRequest<PriceAlertEntity>(entityName: "PriceAlertEntity")
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        return request
    }

    @NSManaged var id: String
    @NSManaged var name: String
    @NSManaged var image: String
    @NSManaged var imageData: Data
    @NSManaged var rank: Int16
    @NSManaged var currentPrice: Double
    @NSManaged var priceChange: Double
    @NSManaged var targetPrice: NSNumber?
    @NSManaged var isActive: Bool
}
