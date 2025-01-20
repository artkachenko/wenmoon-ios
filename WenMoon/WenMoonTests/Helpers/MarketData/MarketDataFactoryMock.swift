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
                priceChange24H: .random(in: -10_000...10_000)
            )
            marketDataDict[coin.id] = marketData
        }
        return marketDataDict
    }
}
