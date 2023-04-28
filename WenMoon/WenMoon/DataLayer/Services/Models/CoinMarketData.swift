//
//  CoinMarketData.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 26.04.23.
//

import Foundation

struct CoinMarketData: Codable {
    let usd: Double
    let usd24HChange: Double
}

// MARK: - Mocks

extension CoinMarketData {
    static let mock = ["bitcoin": CoinMarketData(usd: 28952, usd24HChange: 0.81),
                       "ethereum": CoinMarketData(usd: 1882.93, usd24HChange: 0.37)]
}
