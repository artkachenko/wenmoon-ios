//
//  PriceAlert+CoreDataProperties.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//
//

import Foundation
import CoreData

extension PriceAlert: Identifiable {
    @nonobjc public class func fetchRequest( sortDescriptors: [NSSortDescriptor] = []) -> NSFetchRequest<PriceAlert> {
        let request = NSFetchRequest<PriceAlert>(entityName: "PriceAlert")
        request.sortDescriptors = sortDescriptors
        return request
    }

    @NSManaged public var id: String
    @NSManaged public var symbol: String
    @NSManaged public var name: String
    @NSManaged public var image: String
}

extension PriceAlert {
    convenience init(coin: Coin, context: NSManagedObjectContext) {
        self.init(context: context)
        id = coin.id
        symbol = coin.symbol
        name = coin.name
        image = coin.image
    }
}
