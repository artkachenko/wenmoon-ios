//
//  CoinSearchResult.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

struct CoinSearchResult: Codable {
    let coins: [Coin]
}

// MARK: - Mocks

extension CoinSearchResult {
    static let mock = CoinSearchResult(coins: [Coin(id: "bitcoin",
                                                    symbol: "btc",
                                                    name: "Bitcoin",
                                                    image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579"),
                                               Coin(id: "ethereum",
                                                    symbol: "eth",
                                                    name: "Ethereum",
                                                    image: "https://assets.coingecko.com/coins/images/279/large/ethereum.png?1595348880")])
    static let emptyMock = CoinSearchResult(coins: [])
}
