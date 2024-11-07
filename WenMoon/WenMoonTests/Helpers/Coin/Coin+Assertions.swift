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
        XCTAssertEqual(coin.marketCapRank, expectedCoin.marketCapRank)
        XCTAssertEqual(coin.fullyDilutedValuation, expectedCoin.fullyDilutedValuation)
        XCTAssertEqual(coin.high24H, expectedCoin.high24H)
        XCTAssertEqual(coin.low24H, expectedCoin.low24H)
        XCTAssertEqual(coin.priceChange24H, expectedCoin.priceChange24H)
        XCTAssertEqual(coin.marketCapChange24H, expectedCoin.marketCapChange24H)
        XCTAssertEqual(coin.marketCapChangePercentage24H, expectedCoin.marketCapChangePercentage24H)
        XCTAssertEqual(coin.circulatingSupply, expectedCoin.circulatingSupply)
        XCTAssertEqual(coin.totalSupply, expectedCoin.totalSupply)
        XCTAssertEqual(coin.maxSupply, expectedCoin.maxSupply)
        XCTAssertEqual(coin.ath, expectedCoin.ath)
        XCTAssertEqual(coin.athChangePercentage, expectedCoin.athChangePercentage)
        XCTAssertEqual(coin.athDate, expectedCoin.athDate)
        XCTAssertEqual(coin.atl, expectedCoin.atl)
        XCTAssertEqual(coin.atlChangePercentage, expectedCoin.atlChangePercentage)
        XCTAssertEqual(coin.atlDate, expectedCoin.atlDate)
        
        if let marketData {
            XCTAssertEqual(coin.currentPrice, marketData[expectedCoin.id]!.currentPrice)
            XCTAssertEqual(coin.marketCap, marketData[expectedCoin.id]!.marketCap)
            XCTAssertEqual(coin.totalVolume, marketData[expectedCoin.id]!.totalVolume)
            XCTAssertEqual(coin.priceChangePercentage24H, marketData[expectedCoin.id]!.priceChangePercentage24H)
        } else {
            XCTAssertEqual(coin.currentPrice, expectedCoin.currentPrice)
            XCTAssertEqual(coin.marketCap, expectedCoin.marketCap)
            XCTAssertEqual(coin.totalVolume, expectedCoin.totalVolume)
            XCTAssertEqual(coin.priceChangePercentage24H, expectedCoin.priceChangePercentage24H)
        }
    }
}
