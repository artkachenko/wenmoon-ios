//
//  CoinDetails+MarketData.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 14.02.25.
//

import Foundation

extension CoinDetails {
    struct MarketData: Codable, Equatable {
        // MARK: - Properties
        let marketCapRank: Int64?
        let fullyDilutedValuation: Double?
        let totalVolume: Double?
        let high24H: Double?
        let low24H: Double?
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
        
        // MARK: - Initializers
        init(
            marketCapRank: Int64? = nil,
            fullyDilutedValuation: Double? = nil,
            totalVolume: Double? = nil,
            high24H: Double? = nil,
            low24H: Double? = nil,
            marketCapChange24H: Double? = nil,
            marketCapChangePercentage24H: Double? = nil,
            circulatingSupply: Double? = nil,
            totalSupply: Double? = nil,
            maxSupply: Double? = nil,
            ath: Double? = nil,
            athChangePercentage: Double? = nil,
            athDate: String? = nil,
            atl: Double? = nil,
            atlChangePercentage: Double? = nil,
            atlDate: String? = nil
        ) {
            self.marketCapRank = marketCapRank
            self.fullyDilutedValuation = fullyDilutedValuation
            self.totalVolume = totalVolume
            self.high24H = high24H
            self.low24H = low24H
            self.marketCapChange24H = marketCapChange24H
            self.marketCapChangePercentage24H = marketCapChangePercentage24H
            self.circulatingSupply = circulatingSupply
            self.totalSupply = totalSupply
            self.maxSupply = maxSupply
            self.ath = ath
            self.athChangePercentage = athChangePercentage
            self.athDate = athDate
            self.atl = atl
            self.atlChangePercentage = atlChangePercentage
            self.atlDate = atlDate
        }
        
        // MARK: - Codable
        private enum CodingKeys: String, CodingKey {
            case marketCapRank, fullyDilutedValuation, totalVolume, high24H, low24H, marketCapChange24H, marketCapChangePercentage24H, circulatingSupply, totalSupply, maxSupply, ath, athChangePercentage, athDate, atl, atlChangePercentage, atlDate
        }
        enum CurrencyKeys: String, CodingKey { case usd }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            func extractDouble(_ key: CodingKeys) -> Double? {
                if let nested = try? container.nestedContainer(keyedBy: CurrencyKeys.self, forKey: key) {
                    return try? nested.decode(Double.self, forKey: .usd)
                }
                return try? container.decode(Double?.self, forKey: key)
            }
            
            func extractString(_ key: CodingKeys) -> String? {
                if let nested = try? container.nestedContainer(keyedBy: CurrencyKeys.self, forKey: key) {
                    return try? nested.decode(String.self, forKey: .usd)
                }
                return try? container.decode(String?.self, forKey: key)
            }
            
            marketCapRank = try container.decodeIfPresent(Int64.self, forKey: .marketCapRank)
            
            fullyDilutedValuation = extractDouble(.fullyDilutedValuation)
            totalVolume = extractDouble(.totalVolume)
            high24H = extractDouble(.high24H)
            low24H = extractDouble(.low24H)
            
            marketCapChange24H = try container.decodeIfPresent(Double.self, forKey: .marketCapChange24H)
            marketCapChangePercentage24H = try container.decodeIfPresent(Double.self, forKey: .marketCapChangePercentage24H)
            circulatingSupply = try container.decode(Double.self, forKey: .circulatingSupply)
            totalSupply = try container.decodeIfPresent(Double.self, forKey: .totalSupply)
            maxSupply = try container.decodeIfPresent(Double.self, forKey: .maxSupply)
            
            ath = extractDouble(.ath)
            athChangePercentage = extractDouble(.athChangePercentage)
            athDate = extractString(.athDate)
            atl = extractDouble(.atl)
            atlChangePercentage = extractDouble(.atlChangePercentage)
            atlDate = extractString(.atlDate)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(marketCapRank, forKey: .marketCapRank)
            
            var fullyDilutedValuationContainer = container.nestedContainer(keyedBy: CurrencyKeys.self, forKey: .fullyDilutedValuation)
            try fullyDilutedValuationContainer.encodeIfPresent(fullyDilutedValuation, forKey: .usd)
            
            var totalVolumeContainer = container.nestedContainer(keyedBy: CurrencyKeys.self, forKey: .totalVolume)
            try totalVolumeContainer.encodeIfPresent(totalVolume, forKey: .usd)
            
            var high24HContainer = container.nestedContainer(keyedBy: CurrencyKeys.self, forKey: .high24H)
            try high24HContainer.encodeIfPresent(high24H, forKey: .usd)
            
            var low24HContainer = container.nestedContainer(keyedBy: CurrencyKeys.self, forKey: .low24H)
            try low24HContainer.encodeIfPresent(low24H, forKey: .usd)
            
            try container.encodeIfPresent(marketCapChange24H, forKey: .marketCapChange24H)
            try container.encodeIfPresent(marketCapChangePercentage24H, forKey: .marketCapChangePercentage24H)
            try container.encodeIfPresent(circulatingSupply, forKey: .circulatingSupply)
            try container.encodeIfPresent(totalSupply, forKey: .totalSupply)
            try container.encodeIfPresent(maxSupply, forKey: .maxSupply)
            
            var athContainer = container.nestedContainer(keyedBy: CurrencyKeys.self, forKey: .ath)
            try athContainer.encodeIfPresent(ath, forKey: .usd)
            
            var athChangePercentageContainer = container.nestedContainer(keyedBy: CurrencyKeys.self, forKey: .athChangePercentage)
            try athChangePercentageContainer.encodeIfPresent(athChangePercentage, forKey: .usd)
            
            var athDateContainer = container.nestedContainer(keyedBy: CurrencyKeys.self, forKey: .athDate)
            try athDateContainer.encodeIfPresent(athDate, forKey: .usd)
            
            var atlContainer = container.nestedContainer(keyedBy: CurrencyKeys.self, forKey: .atl)
            try atlContainer.encodeIfPresent(atl, forKey: .usd)
            
            var atlChangePercentageContainer = container.nestedContainer(keyedBy: CurrencyKeys.self, forKey: .atlChangePercentage)
            try atlChangePercentageContainer.encodeIfPresent(atlChangePercentage, forKey: .usd)
            
            var atlDateContainer = container.nestedContainer(keyedBy: CurrencyKeys.self, forKey: .atlDate)
            try atlDateContainer.encodeIfPresent(atlDate, forKey: .usd)
        }
    }
}
