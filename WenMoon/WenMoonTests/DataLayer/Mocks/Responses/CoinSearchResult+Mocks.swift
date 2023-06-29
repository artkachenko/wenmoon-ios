//
//  CoinSearchResult+Mocks.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 29.06.23.
//

import Foundation
@testable import WenMoon

extension CoinSearchResult {
    static let mock = CoinSearchResult(coins: [.btc, .eth])
    static let emptyMock = CoinSearchResult(coins: [])
}
