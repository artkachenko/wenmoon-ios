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
        fullyDilutedValuation: Double? = .random(in: 1_000_000...10_000_000_000),
        totalVolume: Double? = .random(in: 1_000...1_000_000),
        high24H: Double? = .random(in: 0.01...100_000),
        low24H: Double? = .random(in: 0.01...100_000),
        priceChange24H: Double? = .random(in: -1_000...1_000),
        priceChangePercentage24H: Double? = .random(in: -50...50),
        marketCapChange24H: Double? = .random(in: -1_000_000...1_000_000),
        marketCapChangePercentage24H: Double? = .random(in: -50...50),
        circulatingSupply: Double? = .random(in: 1_000_000...1_000_000_000),
        totalSupply: Double? = .random(in: 1_000_000...1_000_000_000),
        maxSupply: Double? = .random(in: 1_000_000...1_000_000_000),
        ath: Double? = .random(in: 10...100_000),
        athChangePercentage: Double? = .random(in: -90...0),
        athDate: String? = "2023-01-01T00:00:00Z",
        atl: Double? = .random(in: 0.001...10),
        atlChangePercentage: Double? = .random(in: 0...1_000),
        atlDate: String? = "2022-01-01T00:00:00Z"
    ) -> Coin {
        .init(
            id: id,
            symbol: symbol,
            name: name,
            image: image,
            currentPrice: currentPrice,
            marketCap: marketCap,
            marketCapRank: marketCapRank,
            fullyDilutedValuation: fullyDilutedValuation,
            totalVolume: totalVolume,
            high24H: high24H,
            low24H: low24H,
            priceChange24H: priceChange24H,
            priceChangePercentage24H: priceChangePercentage24H,
            marketCapChange24H: marketCapChange24H,
            marketCapChangePercentage24H: marketCapChangePercentage24H,
            circulatingSupply: circulatingSupply,
            totalSupply: totalSupply,
            maxSupply: maxSupply,
            ath: ath,
            athChangePercentage: athChangePercentage,
            athDate: athDate,
            atl: atl,
            atlChangePercentage: atlChangePercentage,
            atlDate: atlDate
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
        fullyDilutedValuation: Double? = .random(in: 1_000_000...10_000_000_000),
        totalVolume: Double? = .random(in: 1_000...1_000_000),
        high24H: Double? = .random(in: 0.01...100_000),
        low24H: Double? = .random(in: 0.01...100_000),
        priceChange24H: Double? = .random(in: -1_000...1_000),
        priceChangePercentage24H: Double? = .random(in: -50...50),
        marketCapChange24H: Double? = .random(in: -1_000_000...1_000_000),
        marketCapChangePercentage24H: Double? = .random(in: -50...50),
        circulatingSupply: Double? = .random(in: 1_000_000...1_000_000_000),
        totalSupply: Double? = .random(in: 1_000_000...1_000_000_000),
        maxSupply: Double? = .random(in: 1_000_000...1_000_000_000),
        ath: Double? = .random(in: 10...100_000),
        athChangePercentage: Double? = .random(in: -90...0),
        athDate: String? = "2023-01-01T00:00:00Z",
        atl: Double? = .random(in: 0.001...10),
        atlChangePercentage: Double? = .random(in: 0...1_000),
        atlDate: String? = "2022-01-01T00:00:00Z",
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
            fullyDilutedValuation: fullyDilutedValuation,
            totalVolume: totalVolume,
            high24H: high24H,
            low24H: low24H,
            priceChange24H: priceChange24H,
            priceChangePercentage24H: priceChangePercentage24H,
            marketCapChange24H: marketCapChange24H,
            marketCapChangePercentage24H: marketCapChangePercentage24H,
            circulatingSupply: circulatingSupply,
            totalSupply: totalSupply,
            maxSupply: maxSupply,
            ath: ath,
            athChangePercentage: athChangePercentage,
            athDate: athDate,
            atl: atl,
            atlChangePercentage: atlChangePercentage,
            atlDate: atlDate,
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
            fullyDilutedValuation: coin.fullyDilutedValuation,
            totalVolume: coin.totalVolume,
            high24H: coin.high24H,
            low24H: coin.low24H,
            priceChange24H: coin.priceChange24H,
            priceChangePercentage24H: coin.priceChangePercentage24H,
            marketCapChange24H: coin.marketCapChange24H,
            marketCapChangePercentage24H: coin.marketCapChangePercentage24H,
            circulatingSupply: coin.circulatingSupply,
            totalSupply: coin.totalSupply,
            maxSupply: coin.maxSupply,
            ath: coin.ath,
            athChangePercentage: coin.athChangePercentage,
            athDate: coin.athDate,
            atl: coin.atl,
            atlChangePercentage: coin.atlChangePercentage,
            atlDate: coin.atlDate,
            isArchived: isArchived
        )
    }
}
