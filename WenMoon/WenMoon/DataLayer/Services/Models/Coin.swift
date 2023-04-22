//
//  Coin.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

struct Coin: Codable, Identifiable {
    var id: String
    var symbol: String
    var name: String
    var image: String

    enum CodingKeys: String, CodingKey {
        case id, symbol, name, image, thumb
    }

    init(id: String, symbol: String, name: String, image: String) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.image = image
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        symbol = try container.decode(String.self, forKey: .symbol)
        name = try container.decode(String.self, forKey: .name)

        if let image = try? container.decodeIfPresent(String.self, forKey: .image) {
            self.image = image
        } else {
            self.image = try container.decode(String.self, forKey: .thumb)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(symbol, forKey: .symbol)
        try container.encode(name, forKey: .name)
        try container.encode(image, forKey: .image)
    }
}

// MARK: - Mocks

extension Coin {
    enum Page {
        case first
        case second

        var mock: [Coin] {
            switch self {
            case .first:
                return [Coin(id: "bitcoin",
                             symbol: "btc",
                             name: "Bitcoin",
                             image: "https://assets.coingecko.com/coins/images/1/large/bitcoin.png?1547033579"),
                        Coin(id: "ethereum",
                             symbol: "eth",
                             name: "Ethereum",
                             image: "https://assets.coingecko.com/coins/images/279/large/ethereum.png?1595348880")]
            case .second:
                return [Coin(id: "tether",
                             symbol: "usdt",
                             name: "Tether",
                             image: "https://assets.coingecko.com/coins/images/325/large/Tether.png?1668148663"),
                        Coin(id: "binancecoin",
                             symbol: "bnb",
                             name: "BNB",
                             image: "https://assets.coingecko.com/coins/images/825/large/bnb-icon2_2x.png?1644979850")]
            }
        }
    }
}
