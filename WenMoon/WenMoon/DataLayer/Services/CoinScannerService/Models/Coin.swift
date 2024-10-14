//
//  Coin.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

struct Coin: Codable {

    var id: String
    var name: String
    var imageURL: URL?
    var marketCapRank: Int16?
    var currentPrice: Double?
    var priceChangePercentage24H: Double?

    private enum CodingKeys: String, CodingKey {
        case id, name, imageURL = "image", large, marketCapRank, currentPrice, priceChangePercentage24H
    }

    init(id: String,
         name: String,
         imageURL: URL?,
         marketCapRank: Int16?,
         currentPrice: Double?,
         priceChangePercentage24H: Double?) {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.marketCapRank = marketCapRank
        self.currentPrice = currentPrice
        self.priceChangePercentage24H = priceChangePercentage24H
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        imageURL = try container.decodeIfPresent(URL.self, forKey: .imageURL)
        marketCapRank = try container.decodeIfPresent(Int16.self, forKey: .marketCapRank)
        currentPrice = try container.decodeIfPresent(Double.self, forKey: .currentPrice)
        priceChangePercentage24H = try container.decodeIfPresent(Double.self, forKey: .priceChangePercentage24H)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(marketCapRank, forKey: .marketCapRank)
        try container.encode(currentPrice, forKey: .currentPrice)
        try container.encode(priceChangePercentage24H, forKey: .priceChangePercentage24H)
    }
}

extension Coin: Hashable {}
