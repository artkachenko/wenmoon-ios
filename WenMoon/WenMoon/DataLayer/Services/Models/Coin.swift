//
//  Coin.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

struct Coin: Codable {

    struct Image: Codable {
        let large: String
    }

    var id: String
    var name: String
    var image: String
    var marketCapRank: Int16?
    var currentPrice: Double?
    var priceChangePercentage24H: Double?

    private enum CodingKeys: String, CodingKey {
        case id, name, image, large, marketCapRank, currentPrice, priceChangePercentage24H
    }

    init(id: String,
         name: String,
         image: String,
         marketCapRank: Int16?,
         currentPrice: Double?,
         priceChangePercentage24H: Double?) {
        self.id = id
        self.name = name
        self.image = image
        self.marketCapRank = marketCapRank
        self.currentPrice = currentPrice
        self.priceChangePercentage24H = priceChangePercentage24H
    }

    init(priceAlert: PriceAlert) {
        id = priceAlert.id
        name = priceAlert.name
        image = priceAlert.image
        marketCapRank = priceAlert.rank
        currentPrice = priceAlert.currentPrice
        priceChangePercentage24H = priceAlert.priceChange
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        marketCapRank = try? container.decodeIfPresent(Int16.self, forKey: .marketCapRank)
        currentPrice = try? container.decodeIfPresent(Double.self, forKey: .currentPrice)
        priceChangePercentage24H = try? container.decodeIfPresent(Double.self, forKey: .priceChangePercentage24H)

        if let image = try? container.decodeIfPresent(String.self, forKey: .image) {
            self.image = image
        } else if let image = try? container.decodeIfPresent(Image.self, forKey: .image) {
            self.image = image.large
        } else {
            self.image = try container.decode(String.self, forKey: .large)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(image, forKey: .image)
        try container.encode(marketCapRank, forKey: .marketCapRank)
        try container.encode(currentPrice, forKey: .currentPrice)
        try container.encode(priceChangePercentage24H, forKey: .priceChangePercentage24H)
    }
}

extension Coin: Hashable {}

// MARK: - Mocks

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
