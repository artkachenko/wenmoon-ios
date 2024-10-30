//
//  MarketData+Assertions.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 24.10.24.
//

import Foundation
import XCTest
@testable import WenMoon

func assertMarketDataEqual(for coins: [CoinData], with marketData: [String: MarketData]) {
    XCTAssertEqual(coins.count, marketData.count)
    for coin in coins {
        XCTAssertEqual(coin.currentPrice, marketData[coin.id]!.currentPrice)
        XCTAssertEqual(coin.priceChange, marketData[coin.id]!.priceChange)
    }
}

func assertMarketDataEqual(
    _ marketData: [String: MarketData],
    _ expectedMarketData: [String: MarketData],
    for coinIDs: [String]
) {
    XCTAssertEqual(marketData.count, expectedMarketData.count)
    for coinID in coinIDs {
        XCTAssertEqual(marketData[coinID]!.currentPrice, expectedMarketData[coinID]!.currentPrice)
        XCTAssertEqual(marketData[coinID]!.priceChange, expectedMarketData[coinID]!.priceChange)
    }
}
