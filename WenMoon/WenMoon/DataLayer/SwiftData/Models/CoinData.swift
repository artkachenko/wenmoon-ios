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
    var rank: Int64
    var currentPrice: Double
    var priceChange: Double
    var imageURL: URL?
    var imageData: Data?
    var targetPrice: Double?
    var isActive: Bool

    init(id: String = "",
         name: String = "",
         rank: Int64 = .zero,
         currentPrice: Double = .zero,
         priceChange: Double = .zero,
         imageURL: URL? = nil,
         imageData: Data? = nil,
         targetPrice: Double? = nil,
         isActive: Bool = false) {
        self.id = id
        self.name = name
        self.rank = rank
        self.currentPrice = currentPrice
        self.priceChange = priceChange
        self.imageURL = imageURL
        self.imageData = imageData
        self.targetPrice = targetPrice
        self.isActive = isActive
    }
}

extension CoinData {
    static let predefinedCoins = [
        CoinData(id: "bitcoin", name: "Bitcoin", rank: 1, imageURL: URL(string: "https://coin-images.coingecko.com/coins/images/1/large/bitcoin.png?1696501400")!),
        CoinData(id: "ethereum", name: "Ethereum", rank: 2, imageURL: URL(string: "https://coin-images.coingecko.com/coins/images/279/large/ethereum.png?1696501628")!),
        CoinData(id: "solana", name: "Solana", rank: 5, imageURL: URL(string: "https://coin-images.coingecko.com/coins/images/4128/large/solana.png?1718769756")!),
        CoinData(id: "sui", name: "Sui", rank: 22, imageURL: URL(string: "https://coin-images.coingecko.com/coins/images/26375/large/sui-ocean-square.png?1727791290")!),
        CoinData(id: "bittensor", name: "Bittensor", rank: 27, imageURL: URL(string: "https://coin-images.coingecko.com/coins/images/28452/large/ARUsPeNQ_400x400.jpeg?1696527447")!),
        CoinData(id: "pepe", name: "Pepe", rank: 28, imageURL: URL(string: "https://coin-images.coingecko.com/coins/images/29850/large/pepe-token.jpeg?1696528776")!)
    ]
}
