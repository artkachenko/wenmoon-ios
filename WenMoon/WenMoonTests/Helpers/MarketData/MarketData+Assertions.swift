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
        XCTAssertEqual(coin.currentPrice, marketData[coin.id]!.currentPrice)
        XCTAssertEqual(coin.marketCap, marketData[coin.id]!.marketCap)
        XCTAssertEqual(coin.totalVolume, marketData[coin.id]!.totalVolume)
        XCTAssertEqual(coin.priceChangePercentage24H, marketData[coin.id]!.priceChangePercentage24H)
    }
}

func assertMarketDataEqual(
    _ marketData: [String: MarketData],
    _ expectedMarketData: [String: MarketData],
    for ids: [String]
) {
    XCTAssertEqual(marketData.count, expectedMarketData.count)
    for id in ids {
        XCTAssertEqual(marketData[id]!.currentPrice, expectedMarketData[id]!.currentPrice)
        XCTAssertEqual(marketData[id]!.marketCap, expectedMarketData[id]!.marketCap)
        XCTAssertEqual(marketData[id]!.totalVolume, expectedMarketData[id]!.totalVolume)
        XCTAssertEqual(marketData[id]!.priceChangePercentage24H, expectedMarketData[id]!.priceChangePercentage24H)
    }
}
