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
        id: String,
        name: String,
        imageURL: URL?,
        marketCapRank: Int64?,
        currentPrice: Double?,
        priceChangePercentage24H: Double?
    ) -> Coin {
        .init(
            id: id,
            name: name,
            imageURL: imageURL,
            marketCapRank: marketCapRank,
            currentPrice: currentPrice,
            priceChangePercentage24H: priceChangePercentage24H
        )
    }
    
    static func makeBitcoin() -> Coin {
        makeCoin(
            id: "bitcoin",
            name: "Bitcoin",
            imageURL: nil,
            marketCapRank: 1,
            currentPrice: 65000,
            priceChangePercentage24H: -5
        )
    }
    
    static func makeEthereum() -> Coin {
        makeCoin(
            id: "ethereum",
            name: "Ethereum",
            imageURL: nil,
            marketCapRank: 2,
            currentPrice: 2000,
            priceChangePercentage24H: 2
        )
    }
    
    static func makeBNB() -> Coin {
        makeCoin(
            id: "binancecoin",
            name: "BNB",
            imageURL: nil,
            marketCapRank: 3,
            currentPrice: 600,
            priceChangePercentage24H: -1
        )
    }
    
    static func makeSolana() -> Coin {
        makeCoin(
            id: "solana",
            name: "Solana",
            imageURL: nil,
            marketCapRank: 4,
            currentPrice: 150,
            priceChangePercentage24H: 10
        )
    }
    
    static func makeCoins(at page: Int = 1) -> [Coin] {
        switch page {
        case 1:
            return [makeBitcoin(), makeEthereum()]
        default:
            return [makeBNB(), makeSolana()]
        }
    }
    
    static func makeEmptyCoins() -> [Coin] { [] }
    
    // MARK: - CoinData
    static func makeCoinData(from coin: Coin) -> CoinData {
        let coinData = CoinData()
        coinData.id = coin.id
        coinData.name = coin.name
        coinData.imageURL = coin.imageURL
        coinData.rank = coin.marketCapRank!
        coinData.currentPrice = coin.currentPrice!
        coinData.priceChange = coin.priceChangePercentage24H!
        return coinData
    }
    
    static func makeBitcoinData() -> CoinData {
        makeCoinData(from: makeBitcoin())
    }
    
    static func makeEthereumData() -> CoinData {
        makeCoinData(from: makeEthereum())
    }
    
    static func makeCoinsData() -> [CoinData] {
        [makeBitcoinData(), makeEthereumData()]
    }
}
