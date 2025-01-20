//
//  MarketData.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 26.04.23.
//

import Foundation

struct MarketData: Codable, Equatable {
    let currentPrice: Double?
    let marketCap: Double?
    let priceChange24H: Double?
}
