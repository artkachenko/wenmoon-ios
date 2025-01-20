//
//  CoinDetails.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 05.02.25.
//

import Foundation

struct CoinDetails: Codable, Equatable {
    let id: String
    let marketData: MarketData
    let categories: [String]
    let publicNotice: String?
    let description: Description
    let links: Links
    let countryOrigin: String?
    let genesisDate: String?
    let sentimentVotesUpPercentage: Double?
    let sentimentVotesDownPercentage: Double?
    let watchlistPortfolioUsers: Int?
    let tickers: [Ticker]
    
    // MARK: - Nested Types
    struct MarketData: Codable, Equatable {
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
        
        // MARK: - Decodable
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
            
            marketCapRank = try? container.decode(Int64?.self, forKey: .marketCapRank)
            fullyDilutedValuation = extractDouble(.fullyDilutedValuation)
            totalVolume = extractDouble(.totalVolume)
            high24H = extractDouble(.high24H)
            low24H = extractDouble(.low24H)
            marketCapChange24H = try? container.decode(Double?.self, forKey: .marketCapChange24H)
            marketCapChangePercentage24H = try? container.decode(Double?.self, forKey: .marketCapChangePercentage24H)
            circulatingSupply = try? container.decode(Double?.self, forKey: .circulatingSupply)
            totalSupply = try? container.decode(Double?.self, forKey: .totalSupply)
            maxSupply = try? container.decode(Double?.self, forKey: .maxSupply)
            ath = extractDouble(.ath)
            athChangePercentage = extractDouble(.athChangePercentage)
            athDate = extractString(.athDate)
            atl = extractDouble(.atl)
            atlChangePercentage = extractDouble(.atlChangePercentage)
            atlDate = extractString(.atlDate)
        }
    }
    
    struct Description: Codable, Equatable {
        let en: String?
    }
    
    struct Links: Codable, Equatable {
        let homepage: [String]?
        let whitepaper: String?
        let blockchainSite: [String]?
        let officialForumURL: [String]?
        let chatURL: [String]?
        let announcementURL: [String]?
        let twitterScreenName: String?
        let facebookUsername: String?
        let telegramChannelIdentifier: String?
        let subredditURL: String?
        let reposUrl: ReposURL

        struct ReposURL: Codable, Equatable {
            let github: [String]?
            let bitbucket: [String]?
        }
    }
    
    struct Ticker: Codable, Equatable {
        let base: String
        let target: String
        let market: Market
        let last: Double?
        let volume: Double?
        let convertedLast: [String: Double]?
        let convertedVolume: [String: Double]?
        let trustScore: String?
        let bidAskSpreadPercentage: Double?
        let timestamp: String?
        let lastTradedAt: String?
        let lastFetchAt: String?
        let isAnomaly: Bool?
        let isStale: Bool?
        let tradeURL: String?
        let tokenInfoURL: String?
        let coinId: String?
        let targetCoinId: String?
        
        struct Market: Codable, Equatable {
            let name: String?
            let identifier: String?
            let hasTradingIncentive: Bool?
        }
    }
}

// MARK: - Empty State
extension CoinDetails {
    static let empty = CoinDetails(
        id: "",
        marketData: .empty,
        categories: [],
        publicNotice: nil,
        description: .empty,
        links: .empty,
        countryOrigin: nil,
        genesisDate: nil,
        sentimentVotesUpPercentage: nil,
        sentimentVotesDownPercentage: nil,
        watchlistPortfolioUsers: nil,
        tickers: []
    )
}

extension CoinDetails.MarketData {
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

    static let empty = CoinDetails.MarketData()
}

extension CoinDetails.Description {
    static let empty = CoinDetails.Description(en: nil)
}

extension CoinDetails.Links {
    static let empty = CoinDetails.Links(
        homepage: nil, whitepaper: nil, blockchainSite: nil,
        officialForumURL: nil, chatURL: nil, announcementURL: nil,
        twitterScreenName: nil, facebookUsername: nil,
        telegramChannelIdentifier: nil, subredditURL: nil,
        reposUrl: .empty
    )
}

extension CoinDetails.Links.ReposURL {
    static let empty = CoinDetails.Links.ReposURL(github: nil, bitbucket: nil)
}

extension CoinDetails.Ticker.Market {
    static let empty = CoinDetails.Ticker.Market(name: nil, identifier: nil, hasTradingIncentive: nil)
}
