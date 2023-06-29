//
//  Coin+Mocks.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 29.06.23.
//

import Foundation
@testable import WenMoon

extension Coin {
    static let btc = Coin(id: "bitcoin",
                          name: "Bitcoin",
                          image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579",
                          marketCapRank: 1,
                          currentPrice: 28543,
                          priceChangePercentage24H: -2.39)
    static let eth = Coin(id: "ethereum",
                          name: "Ethereum",
                          image: "https://assets.coingecko.com/coins/images/279/large/ethereum.png?1595348880",
                          marketCapRank: 2,
                          currentPrice: 1847.33,
                          priceChangePercentage24H: -3.01)
}
