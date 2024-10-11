//
//  CoinData.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 11.10.24.
//

import Foundation
import SwiftData

@Model
final class CoinData {

    @Attribute(.unique)
    var id: String
    
    var name: String
    var image: String
    var imageData: Data
    var rank: Int16
    var currentPrice: Double
    var priceChange: Double
    var targetPrice: Double?
    var isActive: Bool

    init(id: String = "",
         name: String = "",
         image: String = "",
         imageData: Data = Data(),
         rank: Int16 = .zero,
         currentPrice: Double = .zero,
         priceChange: Double = .zero,
         targetPrice: Double? = nil,
         isActive: Bool = false) {
        self.id = id
        self.name = name
        self.image = image
        self.imageData = imageData
        self.rank = rank
        self.currentPrice = currentPrice
        self.priceChange = priceChange
        self.targetPrice = targetPrice
        self.isActive = isActive
    }
}
