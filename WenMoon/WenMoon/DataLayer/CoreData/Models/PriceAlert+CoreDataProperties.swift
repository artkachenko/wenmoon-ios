//
//  PriceAlert+CoreDataProperties.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 27.04.23.
//
//

import Foundation
import CoreData

extension PriceAlert: Identifiable {
    @nonobjc public class func fetchRequest(sortDescriptors: [NSSortDescriptor] = [],
                                            predicate: NSPredicate? = nil) -> NSFetchRequest<PriceAlert> {
        let request = NSFetchRequest<PriceAlert>(entityName: "PriceAlert")
        request.sortDescriptors = sortDescriptors
        request.predicate = predicate
        return request
    }

    @NSManaged public var id: String
    @NSManaged public var name: String
    @NSManaged public var image: String
    @NSManaged public var imageData: Data
    @NSManaged public var rank: Int16
    @NSManaged public var currentPrice: Double
    @NSManaged public var priceChange: Double
}
