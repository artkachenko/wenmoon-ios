//
//  CoinFactoryMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 18.10.24.
//

import Foundation
@testable import WenMoon

struct CoinFactoryMock {
    // MARK: - Coin
    static func makeCoin(
        id: String = "coin-1",
        name: String = "Coin 1",
        imageData: Data? = nil,
        marketCapRank: Int64 = .random(in: 1...2500),
        currentPrice: Double = .random(in: 0.01...100000),
        priceChange: Double = .random(in: -50...50)
    ) -> Coin {
        .init(
            id: id,
            name: name,
            imageData: imageData,
            marketCapRank: marketCapRank,
            currentPrice: currentPrice,
            priceChange: priceChange
        )
    }
    
    static func makeCoins(count: Int = 10, at page: Int = 1) -> [Coin] {
        let startIndex = (page - 1) * count + 1
        return (startIndex..<startIndex + count).map { index in
            makeCoin(
                id: "coin-\(index)",
                name: "Coin \(index)"
            )
        }
    }
    
    // MARK: - CoinData
    static func makeCoinData(from coin: Coin) -> CoinData {
        let coinData = CoinData()
        coinData.id = coin.id
        coinData.name = coin.name
        coinData.imageData = coin.imageData
        coinData.rank = coin.marketCapRank
        coinData.currentPrice = coin.currentPrice
        coinData.priceChange = coin.priceChange
        return coinData
    }
    
    static func makeCoinData() -> CoinData {
        let coin = makeCoin()
        return makeCoinData(from: coin)
    }
    
    static func makeCoinsData(count: Int = 10) -> [CoinData] {
        makeCoins(count: count).map { makeCoinData(from: $0) }
    }
}
