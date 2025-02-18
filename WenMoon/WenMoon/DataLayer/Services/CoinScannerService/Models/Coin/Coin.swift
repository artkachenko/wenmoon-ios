//
//  Coin.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

protocol CoinProtocol {
    var id: String { get }
    var symbol: String { get }
    var name: String { get }
    var image: URL? { get }
    var currentPrice: Double? { get }
    var marketCap: Double? { get }
    var priceChangePercentage24H: Double? { get }
}

struct Coin: Codable {
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
}

extension Coin: Hashable {}
extension Coin: CoinProtocol {}
