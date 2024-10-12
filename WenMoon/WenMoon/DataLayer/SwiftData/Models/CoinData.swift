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

extension CoinData {
    static let predefinedCoins = [
        CoinData(id: "bitcoin", name: "Bitcoin", image: "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400", rank: 1),
        CoinData(id: "ethereum", name: "Ethereum", image: "https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628", rank: 2),
        CoinData(id: "solana", name: "Solana", image: "https://coin-images.coingecko.com/coins/images/4128/large/solana.png?1718769756", rank: 5),
        CoinData(id: "sui", name: "Sui", image: "https://coin-images.coingecko.com/coins/images/26375/large/sui-ocean-square.png?1727791290", rank: 22),
        CoinData(id: "bittensor", name: "Bittensor", image: "https://coin-images.coingecko.com/coins/images/28452/large/ARUsPeNQ_400x400.jpeg?1696527447", rank: 27),
        CoinData(id: "pepe", name: "Pepe", image: "https://coin-images.coingecko.com/coins/images/29850/large/pepe-token.jpeg?1696528776", rank: 28)
    ]
}
