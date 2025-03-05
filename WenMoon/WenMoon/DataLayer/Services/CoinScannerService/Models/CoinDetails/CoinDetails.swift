//
//  CoinDetails.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 05.02.25.
//

import Foundation

struct CoinDetails: Codable, Equatable {
    // MARK: - Properties
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
    private enum CodingKeys: String, CodingKey {
        case id
        case marketData
        case categories
        case publicNotice
        case description
        case links
        case countryOrigin
        case genesisDate
        case sentimentVotesUpPercentage
        case sentimentVotesDownPercentage
        case watchlistPortfolioUsers
        case tickers
    }
    
    private enum DescriptionKeys: String, CodingKey { case en }
    
    // MARK: - Initializers
    init(
        id: String = "",
        marketData: MarketData = .init(),
        categories: [String] = [],
        publicNotice: String? = nil,
        description: String? = nil,
        links: Links = .init(),
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        marketData = try container.decode(MarketData.self, forKey: .marketData)
        categories = try container.decode([String].self, forKey: .categories)
        publicNotice = try? container.decode(String?.self, forKey: .publicNotice)
        
        if let descriptionContainer = try? container.nestedContainer(keyedBy: DescriptionKeys.self, forKey: .description) {
            description = try? descriptionContainer.decode(String?.self, forKey: .en)
        } else {
            description = nil
        }
        
        links = try container.decode(Links.self, forKey: .links)
        countryOrigin = try? container.decode(String?.self, forKey: .countryOrigin)
        genesisDate = try? container.decode(String?.self, forKey: .genesisDate)
        sentimentVotesUpPercentage = try? container.decode(Double?.self, forKey: .sentimentVotesUpPercentage)
        sentimentVotesDownPercentage = try? container.decode(Double?.self, forKey: .sentimentVotesDownPercentage)
        watchlistPortfolioUsers = try? container.decode(Int?.self, forKey: .watchlistPortfolioUsers)
        tickers = try container.decode([Ticker].self, forKey: .tickers)
    }
    
    // MARK: - Encodable
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(marketData, forKey: .marketData)
        try container.encode(categories, forKey: .categories)
        try container.encode(publicNotice, forKey: .publicNotice)
        
        var descriptionContainer = container.nestedContainer(keyedBy: DescriptionKeys.self, forKey: .description)
        try descriptionContainer.encode(description, forKey: .en)
        
        try container.encode(links, forKey: .links)
        try container.encode(countryOrigin, forKey: .countryOrigin)
        try container.encode(genesisDate, forKey: .genesisDate)
        try container.encode(sentimentVotesUpPercentage, forKey: .sentimentVotesUpPercentage)
        try container.encode(sentimentVotesDownPercentage, forKey: .sentimentVotesDownPercentage)
        try container.encode(watchlistPortfolioUsers, forKey: .watchlistPortfolioUsers)
        try container.encode(tickers, forKey: .tickers)
    }
}
