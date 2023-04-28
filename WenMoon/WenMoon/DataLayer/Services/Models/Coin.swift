//
//  Coin.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

struct Coin: Codable, Identifiable, Hashable {

    struct Image: Codable {
        let large: String
    }

    var id: String
    var name: String
    var image: String
    var marketCapRank: Int16

    enum CodingKeys: String, CodingKey {
        case id, name, image, large, marketCapRank
    }

    init(id: String, name: String, image: String, marketCapRank: Int16) {
        self.id = id
        self.name = name
        self.image = image
        self.marketCapRank = marketCapRank
    }

    init(priceAlert: PriceAlert) {
        id = priceAlert.id
        name = priceAlert.name
        image = priceAlert.image
        marketCapRank = priceAlert.rank
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        marketCapRank = try container.decode(Int16.self, forKey: .marketCapRank)

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
    }
}

// MARK: - Mocks

extension Coin {
    static let btc = Coin(id: "bitcoin",
                          name: "Bitcoin",
                          image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579",
                          marketCapRank: 1)
    static let eth = Coin(id: "ethereum",
                          name: "Ethereum",
                          image: "https://assets.coingecko.com/coins/images/279/large/ethereum.png?1595348880",
                          marketCapRank: 2)
    static let bnb = Coin(id: "binancecoin",
                          name: "BNB",
                          image: "https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png?1644979850",
                          marketCapRank: 4)
    static let lyxe = Coin(id: "lukso-token",
                           name: "LUKSO",
                           image: "https://assets.coingecko.com/coins/images/11423/thumb/1_QAHTciwVhD7SqVmfRW70Pw.png",
                           marketCapRank: 173)
}
