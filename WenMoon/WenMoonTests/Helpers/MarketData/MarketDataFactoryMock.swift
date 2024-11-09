//
//  MarketDataFactoryMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 29.06.23.
//

import Foundation
@testable import WenMoon

struct MarketDataFactoryMock {
    static func makeMarketData(for coins: [CoinProtocol] = CoinFactoryMock.makeCoins()) -> [String: MarketData] {
        var marketDataDict: [String: MarketData] = [:]
        for coin in coins {
            let marketData = MarketData(
                currentPrice: .random(in: 0.01...100_000),
                marketCap: .random(in: 1_000...1_000_000_000),
                marketCapRank: Int64.random(in: 1...1_000),
                fullyDilutedValuation: .random(in: 1_000...2_000_000_000),
                totalVolume: .random(in: 1_000...1_000_000),
                high24H: .random(in: 0.01...100_000),
                low24H: .random(in: 0.01...100_000),
                priceChange24H: .random(in: -10_000...10_000),
                priceChangePercentage24H: .random(in: -50...50),
                marketCapChange24H: .random(in: -1_000_000...1_000_000),
                marketCapChangePercentage24H: .random(in: -50...50),
                circulatingSupply: .random(in: 1_000_000...1_000_000_000),
                totalSupply: .random(in: 1_000_000...1_000_000_000),
                ath: .random(in: 0.01...100_000),
                athChangePercentage: .random(in: -100...100),
                athDate: "2024-11-08",
                atl: .random(in: 0.01...100_000),
                atlChangePercentage: .random(in: -100...100),
                atlDate: "2024-11-07"
            )
            marketDataDict[coin.id] = marketData
        }
        return marketDataDict
    }
}
