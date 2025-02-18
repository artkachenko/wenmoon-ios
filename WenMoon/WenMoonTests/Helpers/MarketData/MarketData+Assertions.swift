//
//  MarketData+Assertions.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 24.10.24.
//

import Foundation
import XCTest
@testable import WenMoon

func assertMarketDataEqual(for coins: [CoinProtocol], with marketData: [String: MarketData]) {
    XCTAssertEqual(coins.count, marketData.count)
    for coin in coins {
        let expectedMarketData = marketData[coin.id]!
        XCTAssertEqual(coin.currentPrice, expectedMarketData.currentPrice)
        XCTAssertEqual(coin.marketCap, expectedMarketData.marketCap)
        XCTAssertEqual(coin.priceChangePercentage24H, expectedMarketData.priceChangePercentage24H)
    }
}

func assertMarketDataEqual(
    _ marketData: [String: MarketData],
    _ expectedMarketData: [String: MarketData],
    for ids: [String]
) {
    XCTAssertEqual(marketData.count, expectedMarketData.count)
    for id in ids {
        let marketData = marketData[id]!
        let expectedMarketData = expectedMarketData[id]!
        XCTAssertEqual(marketData, expectedMarketData)
    }
}
