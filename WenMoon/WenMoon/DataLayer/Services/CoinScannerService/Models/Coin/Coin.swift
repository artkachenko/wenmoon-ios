//
//  Coin.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

// MARK: - CoinProtocol
protocol CoinProtocol {
    var id: String { get }
    var symbol: String { get }
    var name: String { get }
    var image: URL? { get }
    var currentPrice: Double? { get }
    var marketCap: Double? { get }
    var priceChangePercentage24H: Double? { get }
}

// MARK: - Coin
struct Coin: CoinProtocol, Codable, Hashable {
    // MARK: - Properties
    var id: String
    var symbol: String
    var name: String
    var image: URL?
    var currentPrice: Double?
    var marketCap: Double?
    var marketCapRank: Int64?
    var priceChangePercentage24H: Double?
    var circulatingSupply: Double?
    var ath: Double?
    
    // MARK: - Initializers
    init(
        id: String,
        symbol: String,
        name: String,
        image: URL? = nil,
        currentPrice: Double? = nil,
        marketCap: Double? = nil,
        marketCapRank: Int64? = nil,
        priceChangePercentage24H: Double? = nil,
        circulatingSupply: Double? = nil,
        ath: Double? = nil
    ) {
        self.id = id
        self.symbol = symbol
        self.name = name
        self.image = image
        self.currentPrice = currentPrice
        self.marketCap = marketCap
        self.marketCapRank = marketCapRank
        self.priceChangePercentage24H = priceChangePercentage24H
        self.circulatingSupply = circulatingSupply
        self.ath = ath
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        symbol = try container.decode(String.self, forKey: .symbol)
        name = try container.decode(String.self, forKey: .name)
        
        image = try container.decodeIfPresent(SafeURL.self, forKey: .image)?.url
        currentPrice = try container.decodeIfPresent(Double.self, forKey: .currentPrice)
        marketCap = try container.decodeIfPresent(Double.self, forKey: .marketCap)
        marketCapRank = try container.decodeIfPresent(Int64.self, forKey: .marketCapRank)
        priceChangePercentage24H = try container.decodeIfPresent(Double.self, forKey: .priceChangePercentage24H)
        circulatingSupply = try container.decodeIfPresent(Double.self, forKey: .circulatingSupply)
        ath = try container.decodeIfPresent(Double.self, forKey: .ath)
    }
}
