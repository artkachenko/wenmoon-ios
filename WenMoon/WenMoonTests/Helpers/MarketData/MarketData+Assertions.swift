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
        XCTAssertEqual(coin.marketCapRank, expectedMarketData.marketCapRank)
        XCTAssertEqual(coin.fullyDilutedValuation, expectedMarketData.fullyDilutedValuation)
        XCTAssertEqual(coin.totalVolume, expectedMarketData.totalVolume)
        XCTAssertEqual(coin.high24H, expectedMarketData.high24H)
        XCTAssertEqual(coin.low24H, expectedMarketData.low24H)
        XCTAssertEqual(coin.priceChange24H, expectedMarketData.priceChange24H)
        XCTAssertEqual(coin.priceChangePercentage24H, expectedMarketData.priceChangePercentage24H)
        XCTAssertEqual(coin.marketCapChange24H, expectedMarketData.marketCapChange24H)
        XCTAssertEqual(coin.marketCapChangePercentage24H, expectedMarketData.marketCapChangePercentage24H)
        XCTAssertEqual(coin.circulatingSupply, expectedMarketData.circulatingSupply)
        XCTAssertEqual(coin.totalSupply, expectedMarketData.totalSupply)
        XCTAssertEqual(coin.ath, expectedMarketData.ath)
        XCTAssertEqual(coin.athChangePercentage, expectedMarketData.athChangePercentage)
        XCTAssertEqual(coin.athDate, expectedMarketData.athDate)
        XCTAssertEqual(coin.atl, expectedMarketData.atl)
        XCTAssertEqual(coin.atlChangePercentage, expectedMarketData.atlChangePercentage)
        XCTAssertEqual(coin.atlDate, expectedMarketData.atlDate)
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
        XCTAssertEqual(marketData.currentPrice, expectedMarketData.currentPrice)
        XCTAssertEqual(marketData.marketCap, expectedMarketData.marketCap)
        XCTAssertEqual(marketData.marketCapRank, expectedMarketData.marketCapRank)
        XCTAssertEqual(marketData.fullyDilutedValuation, expectedMarketData.fullyDilutedValuation)
        XCTAssertEqual(marketData.totalVolume, expectedMarketData.totalVolume)
        XCTAssertEqual(marketData.high24H, expectedMarketData.high24H)
        XCTAssertEqual(marketData.low24H, expectedMarketData.low24H)
        XCTAssertEqual(marketData.priceChange24H, expectedMarketData.priceChange24H)
        XCTAssertEqual(marketData.priceChangePercentage24H, expectedMarketData.priceChangePercentage24H)
        XCTAssertEqual(marketData.marketCapChange24H, expectedMarketData.marketCapChange24H)
        XCTAssertEqual(marketData.marketCapChangePercentage24H, expectedMarketData.marketCapChangePercentage24H)
        XCTAssertEqual(marketData.circulatingSupply, expectedMarketData.circulatingSupply)
        XCTAssertEqual(marketData.totalSupply, expectedMarketData.totalSupply)
        XCTAssertEqual(marketData.ath, expectedMarketData.ath)
        XCTAssertEqual(marketData.athChangePercentage, expectedMarketData.athChangePercentage)
        XCTAssertEqual(marketData.athDate, expectedMarketData.athDate)
        XCTAssertEqual(marketData.atl, expectedMarketData.atl)
        XCTAssertEqual(marketData.atlChangePercentage, expectedMarketData.atlChangePercentage)
        XCTAssertEqual(marketData.atlDate, expectedMarketData.atlDate)
    }
}
