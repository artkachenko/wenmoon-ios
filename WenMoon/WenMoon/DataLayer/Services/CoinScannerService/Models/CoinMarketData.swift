//
//  CoinMarketData.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 26.04.23.
//

import Foundation

struct MarketData: Codable {
    let currentPrice: Double?
    let marketCap: Double?
    let totalVolume: Double?
    let priceChangePercentage24H: Double?
}
