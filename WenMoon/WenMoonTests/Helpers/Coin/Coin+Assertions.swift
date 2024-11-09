//
//  Coin+Assertions.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 18.10.24.
//

import Foundation
import XCTest
@testable import WenMoon

func assertCoinsEqual(_ coins: [CoinProtocol], _ expectedCoins: [CoinProtocol], marketData: [String: MarketData]? = nil) {
    XCTAssertEqual(coins.count, expectedCoins.count)
    for (index, _) in coins.enumerated() {
        let coin = coins[index]
        let expectedCoin = expectedCoins[index]
        XCTAssertEqual(coin.id, expectedCoin.id)
        XCTAssertEqual(coin.symbol, expectedCoin.symbol)
        XCTAssertEqual(coin.name, expectedCoin.name)
        XCTAssertEqual(coin.image, expectedCoin.image)
        XCTAssertEqual(coin.maxSupply, expectedCoin.maxSupply)
        
        if let marketData {
            let expectedMarketData = marketData[expectedCoin.id]!
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
        } else {
            XCTAssertEqual(coin.currentPrice, expectedCoin.currentPrice)
            XCTAssertEqual(coin.marketCap, expectedCoin.marketCap)
            XCTAssertEqual(coin.marketCapRank, expectedCoin.marketCapRank)
            XCTAssertEqual(coin.fullyDilutedValuation, expectedCoin.fullyDilutedValuation)
            XCTAssertEqual(coin.totalVolume, expectedCoin.totalVolume)
            XCTAssertEqual(coin.high24H, expectedCoin.high24H)
            XCTAssertEqual(coin.low24H, expectedCoin.low24H)
            XCTAssertEqual(coin.priceChange24H, expectedCoin.priceChange24H)
            XCTAssertEqual(coin.priceChangePercentage24H, expectedCoin.priceChangePercentage24H)
            XCTAssertEqual(coin.marketCapChange24H, expectedCoin.marketCapChange24H)
            XCTAssertEqual(coin.marketCapChangePercentage24H, expectedCoin.marketCapChangePercentage24H)
            XCTAssertEqual(coin.circulatingSupply, expectedCoin.circulatingSupply)
            XCTAssertEqual(coin.totalSupply, expectedCoin.totalSupply)
            XCTAssertEqual(coin.ath, expectedCoin.ath)
            XCTAssertEqual(coin.athChangePercentage, expectedCoin.athChangePercentage)
            XCTAssertEqual(coin.athDate, expectedCoin.athDate)
            XCTAssertEqual(coin.atl, expectedCoin.atl)
            XCTAssertEqual(coin.atlChangePercentage, expectedCoin.atlChangePercentage)
            XCTAssertEqual(coin.atlDate, expectedCoin.atlDate)
        }
    }
}
