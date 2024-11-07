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
    var marketCapRank: Int64? { get }
    var fullyDilutedValuation: Double? { get }
    var totalVolume: Double? { get }
    var high24H: Double? { get }
    var low24H: Double? { get }
    var priceChange24H: Double? { get }
    var priceChangePercentage24H: Double? { get }
    var marketCapChange24H: Double? { get }
    var marketCapChangePercentage24H: Double? { get }
    var circulatingSupply: Double? { get }
    var totalSupply: Double? { get }
    var maxSupply: Double? { get }
    var ath: Double? { get }
    var athChangePercentage: Double? { get }
    var athDate: String? { get }
    var atl: Double? { get }
    var atlChangePercentage: Double? { get }
    var atlDate: String? { get }
}

struct Coin: Codable {
    let id: String
    let symbol: String
    let name: String
    let image: URL?
    let currentPrice: Double?
    let marketCap: Double?
    let marketCapRank: Int64?
    let fullyDilutedValuation: Double?
    let totalVolume: Double?
    let high24H: Double?
    let low24H: Double?
    let priceChange24H: Double?
    let priceChangePercentage24H: Double?
    let marketCapChange24H: Double?
    let marketCapChangePercentage24H: Double?
    let circulatingSupply: Double?
    let totalSupply: Double?
    let maxSupply: Double?
    let ath: Double?
    let athChangePercentage: Double?
    let athDate: String?
    let atl: Double?
    let atlChangePercentage: Double?
    let atlDate: String?
}

extension Coin: Hashable {}
extension Coin: CoinProtocol {}
