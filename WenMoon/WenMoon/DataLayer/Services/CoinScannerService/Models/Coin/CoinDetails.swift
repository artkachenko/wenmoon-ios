//
//  CoinDetails.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 05.02.25.
//

import Foundation

struct CoinDetails: Decodable, Equatable {
    let id: String
    let marketData: MarketData
    let categories: [String]
    let publicNotice: String?
    let description: String?
    let links: Links
    let countryOrigin: String?
    let genesisDate: String?
    let sentimentVotesUpPercentage: Double?
    let sentimentVotesDownPercentage: Double?
    let watchlistPortfolioUsers: Int?
    let tickers: [Ticker]
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id,
             marketData,
             categories,
             publicNotice,
             description,
             links,
             countryOrigin,
             genesisDate,
             sentimentVotesUpPercentage,
             sentimentVotesDownPercentage,
             watchlistPortfolioUsers,
             tickers
    }
    enum DescriptionKeys: String, CodingKey { case en }
    
    // MARK: - Decodable
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        marketData = try container.decode(MarketData.self, forKey: .marketData)
        categories = try container.decode([String].self, forKey: .categories)
        publicNotice = try? container.decode(String?.self, forKey: .publicNotice)
        links = try container.decode(Links.self, forKey: .links)
        countryOrigin = try? container.decode(String?.self, forKey: .countryOrigin)
        genesisDate = try? container.decode(String?.self, forKey: .genesisDate)
        sentimentVotesUpPercentage = try? container.decode(Double?.self, forKey: .sentimentVotesUpPercentage)
        sentimentVotesDownPercentage = try? container.decode(Double?.self, forKey: .sentimentVotesDownPercentage)
        watchlistPortfolioUsers = try? container.decode(Int?.self, forKey: .watchlistPortfolioUsers)
        tickers = try container.decode([Ticker].self, forKey: .tickers)
        
        if let descriptionContainer = try? container.nestedContainer(keyedBy: DescriptionKeys.self, forKey: .description) {
            description = try? descriptionContainer.decode(String?.self, forKey: .en)
        } else {
            description = nil
        }
    }
    
    // MARK: - Nested Types
    struct MarketData: Decodable, Equatable {
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
        
        // MARK: - Coding Keys
        enum CodingKeys: String, CodingKey {
            case marketCapRank
            case fullyDilutedValuation
            case totalVolume
            case high24H
            case low24H
            case marketCapChange24H
            case marketCapChangePercentage24H
            case circulatingSupply
            case totalSupply
            case maxSupply
            case ath
            case athChangePercentage
            case athDate
            case atl
            case atlChangePercentage
            case atlDate
        }
        enum CurrencyKeys: String, CodingKey { case usd }
        
        // MARK: - Decodable
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
    }
    
    struct Description: Decodable, Equatable {
        let en: String?
    }
    
    struct Links: Decodable, Equatable {
        struct ReposURL: Decodable, Equatable {
            let github: [String]?
        }
        
        let homepage: [String]?
        let whitepaper: String?
        let blockchainSite: [String]?
        let communication: [String]?
        let twitterScreenName: String?
        let telegramChannelIdentifier: String?
        let subredditUrl: String?
        let reposUrl: ReposURL
        
        // MARK: - Coding Keys
        enum CodingKeys: String, CodingKey {
            case homepage
            case whitepaper
            case blockchainSite
            case chatUrl
            case announcementUrl
            case twitterScreenName
            case telegramChannelIdentifier
            case subredditUrl
            case reposUrl
        }
        
        // MARK: - Decodable
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            homepage = try container.decodeIfPresent([String].self, forKey: .homepage)
            whitepaper = try container.decodeIfPresent(String.self, forKey: .whitepaper)
            blockchainSite = try container.decodeIfPresent([String].self, forKey: .blockchainSite)
            
            let chat = try container.decodeIfPresent([String].self, forKey: .chatUrl) ?? []
            let announcement = try container.decodeIfPresent([String].self, forKey: .announcementUrl) ?? []
            communication = chat + announcement
            
            twitterScreenName = try container.decodeIfPresent(String.self, forKey: .twitterScreenName)
            telegramChannelIdentifier = try container.decodeIfPresent(String.self, forKey: .telegramChannelIdentifier)
            subredditUrl = try container.decodeIfPresent(String.self, forKey: .subredditUrl)
            reposUrl = try container.decode(ReposURL.self, forKey: .reposUrl)
        }
    }
    
    struct Ticker: Decodable, Equatable {
        struct Market: Decodable, Equatable {
            let name: String?
            let identifier: String?
            let hasTradingIncentive: Bool?
        }
        
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
        let tradeUrl: String?
        let tokenInfoUrl: String?
        let coinId: String?
        let targetCoinId: String?
    }
}

// MARK: - Empty State
extension CoinDetails {
    init(
        id: String = "",
        marketData: MarketData = .empty,
        categories: [String] = [],
        publicNotice: String? = nil,
        description: String? = nil,
        links: Links = .empty,
        countryOrigin: String? = nil,
        genesisDate: String? = nil,
        sentimentVotesUpPercentage: Double? = nil,
        sentimentVotesDownPercentage: Double? = nil,
        watchlistPortfolioUsers: Int? = nil,
        tickers: [Ticker] = []
    ) {
        self.id = id
        self.marketData = marketData
        self.categories = categories
        self.publicNotice = publicNotice
        self.description = description
        self.links = links
        self.countryOrigin = countryOrigin
        self.genesisDate = genesisDate
        self.sentimentVotesUpPercentage = sentimentVotesUpPercentage
        self.sentimentVotesDownPercentage = sentimentVotesDownPercentage
        self.watchlistPortfolioUsers = watchlistPortfolioUsers
        self.tickers = tickers
    }
    
    static let empty = CoinDetails()
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
    init(
        homepage: [String]? = nil,
        whitepaper: String? = nil,
        blockchainSite: [String]? = nil,
        communication: [String]? = nil,
        twitterScreenName: String? = nil,
        telegramChannelIdentifier: String? = nil,
        subredditUrl: String? = nil,
        reposUrl: ReposURL = .empty
    ) {
        self.homepage = homepage
        self.whitepaper = whitepaper
        self.blockchainSite = blockchainSite
        self.communication = communication
        self.twitterScreenName = twitterScreenName
        self.telegramChannelIdentifier = telegramChannelIdentifier
        self.subredditUrl = subredditUrl
        self.reposUrl = reposUrl
    }
    
    static let empty = CoinDetails.Links()
}

extension CoinDetails.Links.ReposURL {
    static let empty = CoinDetails.Links.ReposURL(github: nil)
}

extension CoinDetails.Ticker.Market {
    static let empty = CoinDetails.Ticker.Market(name: nil, identifier: nil, hasTradingIncentive: nil)
}
