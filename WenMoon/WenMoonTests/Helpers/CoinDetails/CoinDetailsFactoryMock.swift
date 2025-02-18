//
//  CoinDetailsFactoryMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 06.02.25.
//

import Foundation
@testable import WenMoon

struct CoinDetailsFactoryMock {
    static func makeCoinDetails(
        id: String = "coin-1",
        marketData: CoinDetails.MarketData = makeMarketData(),
        categories: [String] = ["Cryptocurrency"],
        publicNotice: String? = nil,
        description: String = "Bitcoin is the first decentralized digital currency, created in 2009 by Satoshi Nakamoto.",
        links: CoinDetails.Links = makeCoinLinks(),
        countryOrigin: String? = "Global",
        genesisDate: String? = "2009-01-03",
        sentimentVotesUpPercentage: Double? = .random(in: 0...99),
        sentimentVotesDownPercentage: Double? = .random(in: 0...99),
        watchlistPortfolioUsers: Int? = .random(in: 0...1_000_000),
        tickers: [CoinDetails.Ticker] = makeCoinTickers()
    ) -> CoinDetails {
        CoinDetails(
            id: id,
            marketData: marketData,
            categories: categories,
            publicNotice: publicNotice,
            description: description,
            links: links,
            countryOrigin: countryOrigin,
            genesisDate: genesisDate,
            sentimentVotesUpPercentage: sentimentVotesUpPercentage,
            sentimentVotesDownPercentage: sentimentVotesDownPercentage,
            watchlistPortfolioUsers: watchlistPortfolioUsers,
            tickers: tickers
        )
    }
    
    static func makeMarketData(
        marketCapRank: Int64? = .random(in: 1...10_000),
        fullyDilutedValuation: Double? = .random(in: 100_000...100_000_000_000),
        totalVolume: Double? = .random(in: 100_000...100_000_000_000),
        high24H: Double? = .random(in: 0.01...100_000),
        low24H: Double? = .random(in: 0.01...100_000),
        marketCapChange24H: Double? = .random(in: -1_000_000_000...1_000_000_000),
        marketCapChangePercentage24H: Double? = .random(in: -99...99),
        circulatingSupply: Double? = .random(in: 100_000...100_000_000_000),
        totalSupply: Double? = .random(in: 100_000...100_000_000_000),
        maxSupply: Double? = .random(in: 100_000...100_000_000_000),
        ath: Double? = .random(in: 0.01...100_000),
        athChangePercentage: Double? = .random(in: -99...0),
        athDate: String? = "2013-07-06T00:00:00Z",
        atl: Double? = .random(in: 0.01...100_000),
        atlChangePercentage: Double? = .random(in: 0...99),
        atlDate: String? = "2013-07-06T00:00:00Z"
    ) -> CoinDetails.MarketData {
        .init(
            marketCapRank: marketCapRank,
            fullyDilutedValuation: fullyDilutedValuation,
            totalVolume: totalVolume,
            high24H: high24H,
            low24H: low24H,
            marketCapChange24H: marketCapChange24H,
            marketCapChangePercentage24H: marketCapChangePercentage24H,
            circulatingSupply: circulatingSupply,
            totalSupply: totalSupply,
            maxSupply: maxSupply,
            ath: ath,
            athChangePercentage: athChangePercentage,
            athDate: athDate,
            atl: atl,
            atlChangePercentage: atlChangePercentage,
            atlDate: atlDate
        )
    }
    
    static func makeCoinLinks() -> CoinDetails.Links {
        CoinDetails.Links(
            homepage: [URL(string: "https://bitcoin.org")!],
            whitepaper: URL(string: "https://bitcoin.org/bitcoin.pdf")!,
            blockchainSite: [URL(string: "https://www.blockchain.com/explorer")!],
            chatUrl: [URL(string: "https://discord.com/invite/bitcoin")!],
            announcementUrl: [URL(string: "https://twitter.com/bitcoin")!],
            twitterScreenName: "bitcoin",
            telegramChannelIdentifier: "bitcoin",
            subredditUrl: URL(string: "https://www.reddit.com/r/bitcoin/")!,
            reposUrl: makeReposURL()
        )
    }
    
    static func makeReposURL() -> CoinDetails.Links.ReposURL {
        CoinDetails.Links.ReposURL(
            github: [URL(string: "https://github.com/bitcoin")!]
        )
    }
    
    static func makeCoinTickers(count: Int = 5) -> [CoinDetails.Ticker] {
        let marketNames = ["Binance", "Coinbase", "Kraken", "Bitstamp", "Crypto.com"]
        let marketIdentifiers = ["binance", "coinbase", "kraken", "bitstamp", "crypto_com"]
        return (0..<count).map { index in
            CoinDetails.Ticker(
                base: "SYM-\(index)",
                target: "USD",
                market: CoinDetails.Ticker.Market(
                    name: marketNames[index % marketNames.count],
                    identifier: marketIdentifiers[index % marketIdentifiers.count],
                    hasTradingIncentive: Bool.random()
                ),
                convertedLast: .random(in: 0.01...100_000),
                convertedVolume: .random(in: 100_000...100_000_000),
                trustScore: [.green, .yellow, .red].randomElement(),
                tradeUrl: URL(string: "https://\(marketIdentifiers[index % marketIdentifiers.count]).com/trade/SYM-\(index)")
            )
        }
    }
}
