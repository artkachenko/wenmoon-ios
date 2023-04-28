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
    static let mock = CoinSearchResult(coins: [.btc, .eth])
    static let emptyMock = CoinSearchResult(coins: [])
}
