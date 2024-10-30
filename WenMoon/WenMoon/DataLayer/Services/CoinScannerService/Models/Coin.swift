//
//  Coin.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

struct Coin: Codable {
    let id: String
    let name: String
    let imageData: Data?
    let marketCapRank: Int64
    let currentPrice: Double
    let priceChange: Double
}

extension Coin: Hashable {}
