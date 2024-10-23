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
            imageURL: URL(string: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579")!,
            marketCapRank: 1,
            currentPrice: 65000,
            priceChangePercentage24H: -5
        )
    }
    
    static func makeEthereum() -> Coin {
        makeCoin(
            id: "ethereum",
            name: "Ethereum",
            imageURL: URL(string: "https://assets.coingecko.com/coins/images/279/large/ethereum.png?1595348880")!,
            marketCapRank: 2,
            currentPrice: 2000,
            priceChangePercentage24H: 2
        )
    }
    
    static func makeCoins() -> [Coin] {
        [makeBitcoin(), makeEthereum()]
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
