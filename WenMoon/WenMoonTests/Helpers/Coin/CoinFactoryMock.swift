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
        symbol: String = "SYM-1",
        name: String = "Coin 1",
        image: URL? = nil,
        currentPrice: Double? = .random(in: 0.01...100_000),
        marketCap: Double? = .random(in: 1_000...1_000_000_000),
        marketCapRank: Int64? = .random(in: 1...1_000),
        priceChangePercentage24H: Double? = .random(in: -50...50),
        circulatingSupply: Double? = .random(in: 1_000_000...1_000_000_000),
        ath: Double? = .random(in: 10...100_000)
    ) -> Coin {
        .init(
            id: id,
            symbol: symbol,
            name: name,
            image: image,
            currentPrice: currentPrice,
            marketCap: marketCap,
            marketCapRank: marketCapRank,
            priceChangePercentage24H: priceChangePercentage24H,
            circulatingSupply: circulatingSupply,
            ath: ath
        )
    }

    static func makeCoins(count: Int = 10, at page: Int = 1) -> [Coin] {
        let startIndex = (page - 1) * count + 1
        return (startIndex..<startIndex + count).map { index in
            makeCoin(
                id: "coin-\(index)",
                symbol: "SYM-\(index)",
                name: "Coin \(index)"
            )
        }
    }

    // MARK: - CoinData
    static func makeCoinData(
        id: String = "coin-1",
        symbol: String = "SYM-1",
        name: String = "Coin 1",
        image: URL? = nil,
        currentPrice: Double? = .random(in: 0.01...100_000),
        marketCap: Double? = .random(in: 1_000...1_000_000_000),
        marketCapRank: Int64? = .random(in: 1...1_000),
        priceChangePercentage24H: Double? = .random(in: -50...50),
        circulatingSupply: Double? = .random(in: 1_000_000...1_000_000_000),
        ath: Double? = .random(in: 10...100_000),
        isArchived: Bool = false
    ) -> CoinData {
        .init(
            id: id,
            symbol: symbol,
            name: name,
            image: image,
            currentPrice: currentPrice,
            marketCap: marketCap,
            marketCapRank: marketCapRank,
            priceChangePercentage24H: priceChangePercentage24H,
            circulatingSupply: circulatingSupply,
            ath: ath,
            isArchived: isArchived
        )
    }

    static func makeCoinsData(count: Int = 10, at page: Int = 1) -> [CoinData] {
        let coins = makeCoins(count: count, at: page)
        return coins.map { makeCoinData(from: $0) }
    }

    static func makeCoinData(from coin: Coin, isArchived: Bool = false) -> CoinData {
        .init(
            id: coin.id,
            symbol: coin.symbol,
            name: coin.name,
            image: coin.image,
            currentPrice: coin.currentPrice,
            marketCap: coin.marketCap,
            marketCapRank: coin.marketCapRank,
            priceChangePercentage24H: coin.priceChangePercentage24H,
            circulatingSupply: coin.circulatingSupply,
            ath: coin.ath,
            isArchived: isArchived
        )
    }
}
