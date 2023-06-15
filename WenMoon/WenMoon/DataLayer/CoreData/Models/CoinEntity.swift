//
//  CoinEntity.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 11.06.23.
//
//

import Foundation
import CoreData

@objc(CoinEntity)
final class CoinEntity: NSManagedObject {

    @nonobjc class func fetchRequest(sortDescriptors: [NSSortDescriptor] = [],
                                     predicate: NSPredicate? = nil) -> NSFetchRequest<CoinEntity> {
        let request = NSFetchRequest<CoinEntity>(entityName: "CoinEntity")
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
