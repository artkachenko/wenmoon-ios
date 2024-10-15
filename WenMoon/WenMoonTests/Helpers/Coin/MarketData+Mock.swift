//
//  MarketData+Mocks.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 29.06.23.
//

import Foundation
@testable import WenMoon

func makeMarketData() -> [String: MarketData] {
    [
        "bitcoin": MarketData(currentPrice: 28952, priceChange: 0.81),
        "ethereum": MarketData(currentPrice: 1882.93, priceChange: 0.37)
    ]
}
