//
//  CoinMarketData.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 26.04.23.
//

import Foundation

struct MarketData: Codable {
    let currentPrice: Double?
    let priceChange: Double?
    
    private enum CodingKeys: String, CodingKey {
        case currentPrice, priceChange
    }
    
    init(currentPrice: Double?, priceChange: Double?) {
        self.currentPrice = currentPrice
        self.priceChange = priceChange
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        currentPrice = try container.decodeIfPresent(Double.self, forKey: .currentPrice)
        priceChange = try container.decodeIfPresent(Double.self, forKey: .priceChange)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currentPrice, forKey: .currentPrice)
        try container.encode(priceChange, forKey: .priceChange)
    }
}
