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
    var symbol: String
    var name: String
    var image: URL?
    var currentPrice: Double?
    var marketCap: Double?
    var marketCapRank: Int64?
    var priceChangePercentage24H: Double?
    var circulatingSupply: Double?
    var ath: Double?
    var imageData: Data?
    var priceAlerts: [PriceAlert]
    var isArchived: Bool
    
    convenience init(
        from coin: Coin,
        imageData: Data? = nil,
        priceAlerts: [PriceAlert] = []
    ) {
        self.init(
            id: coin.id,
            symbol: coin.symbol,
            name: coin.name,
            image: coin.image,
            currentPrice: coin.currentPrice,
            marketCap: coin.marketCap,
            marketCapRank: coin.marketCapRank,
            priceChangePercentage24H: coin.priceChangePercentage24H,
            circulatingSupply: coin.circulatingSupply,
            ath: coin.ath,
            imageData: imageData,
            priceAlerts: priceAlerts,
            isArchived: false
        )
    }
    
    init(
        id: String = "",
        symbol: String = "",
        name: String = "",
        image: URL? = nil,
        currentPrice: Double? = nil,
        marketCap: Double? = nil,
        marketCapRank: Int64? = nil,
        priceChangePercentage24H: Double? = nil,
        circulatingSupply: Double? = nil,
        ath: Double? = nil,
        imageData: Data? = nil,
        priceAlerts: [PriceAlert] = [],
        isArchived: Bool = false
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.image = image
        self.currentPrice = currentPrice
        self.marketCap = marketCap
        self.marketCapRank = marketCapRank
        self.priceChangePercentage24H = priceChangePercentage24H
        self.circulatingSupply = circulatingSupply
        self.ath = ath
        self.imageData = imageData
        self.priceAlerts = priceAlerts
        self.isArchived = isArchived
    }
    
    func updateMarketData(from marketData: MarketData) {
        currentPrice = marketData.currentPrice
        marketCap = marketData.marketCap
        priceChangePercentage24H = marketData.priceChange24H
    }
}

extension CoinData: CoinProtocol {}
