//
//  MarketDataFactoryMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 29.06.23.
//

import Foundation
@testable import WenMoon

struct MarketDataFactoryMock {
    static func makeMarketData(for coins: [Coin] = CoinFactoryMock.makeCoins()) -> [String: MarketData] {
        var marketDataDict: [String: MarketData] = [:]
        for coin in coins {
            let marketData = MarketData(
                currentPrice: .random(in: 1000...70000),
                priceChange: .random(in: -10...10)
            )
            marketDataDict[coin.id] = marketData
        }
        return marketDataDict
    }
}
