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
    var imageData: Data?
    var rank: Int64
    var currentPrice: Double
    var priceChange: Double
    var targetPrice: Double?
    var isActive: Bool
    
    init(
        id: String = "",
        name: String = "",
        imageData: Data? = nil,
        rank: Int64 = .max,
        currentPrice: Double = .zero,
        priceChange: Double = .zero,
        targetPrice: Double? = nil,
        isActive: Bool = false
    ) {
        self.id = id
        self.name = name
        self.imageData = imageData
        self.rank = rank
        self.currentPrice = currentPrice
        self.priceChange = priceChange
        self.targetPrice = targetPrice
        self.isActive = isActive
    }
}

// MARK: - Predefined Coins
extension CoinData {
    static let predefinedCoins =
    [
        CoinData(id: "bitcoin"),
        CoinData(id: "ethereum"),
        CoinData(id: "solana"),
        CoinData(id: "sui"),
        CoinData(id: "bittensor"),
        CoinData(id: "lukso-token-2")
    ]
}
