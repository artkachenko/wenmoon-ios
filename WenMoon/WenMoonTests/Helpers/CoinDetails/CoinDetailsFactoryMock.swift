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
        description: CoinDetails.Description = makeCoinDescription(),
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
    
    static func makeMarketData() -> CoinDetails.MarketData {
        CoinDetails.MarketData(
            marketCapRank: .random(in: 1...10_000),
            fullyDilutedValuation: .random(in: 100_000...100_000_000_000),
            totalVolume: .random(in: 100_000...100_000_000_000),
            high24H: .random(in: 0.01...100_000),
            low24H: .random(in: 0.01...100_000),
            marketCapChange24H: .random(in: -1_000_000_000...1_000_000_000),
            marketCapChangePercentage24H: .random(in: -99...99),
            circulatingSupply: .random(in: 100_000...100_000_000_000),
            totalSupply:  .random(in: 100_000...100_000_000_000),
            maxSupply: .random(in: 100_000...100_000_000_000),
            ath: .random(in: 0.01...100_000),
            athChangePercentage: .random(in: -99...0),
            athDate: "2013-07-06T00:00:00Z",
            atl: .random(in: 0.01...100_000),
            atlChangePercentage: .random(in: 0...99),
            atlDate: "2013-07-06T00:00:00Z"
        )
    }
    
    static func makeCoinDescription() -> CoinDetails.Description {
        CoinDetails.Description(
            en: "Bitcoin is the first decentralized digital currency, created in 2009 by Satoshi Nakamoto."
        )
    }
    
    static func makeCoinLinks() -> CoinDetails.Links {
        CoinDetails.Links(
            homepage: ["https://bitcoin.org"],
            whitepaper: "https://bitcoin.org/bitcoin.pdf",
            blockchainSite: ["https://www.blockchain.com/explorer"],
            officialForumURL: ["https://bitcointalk.org"],
            chatURL: ["https://discord.com/invite/bitcoin"],
            announcementURL: ["https://twitter.com/bitcoin"],
            twitterScreenName: "bitcoin",
            facebookUsername: "bitcoin",
            telegramChannelIdentifier: "bitcoin",
            subredditURL: "https://www.reddit.com/r/bitcoin/",
            reposUrl: makeReposURL()
        )
    }
    
    static func makeReposURL() -> CoinDetails.Links.ReposURL {
        CoinDetails.Links.ReposURL(
            github: ["https://github.com/bitcoin"],
            bitbucket: nil
        )
    }
    
    static func makeCoinTickers() -> [CoinDetails.Ticker] {
        [
            CoinDetails.Ticker(
                base: "BTC",
                target: "USD",
                market: CoinDetails.Ticker.Market(
                    name: "Binance",
                    identifier: "binance",
                    hasTradingIncentive: false
                ),
                last: .random(in: 0.01...100_000),
                volume: .random(in: 100_000...100_000_000),
                convertedLast: ["usd": .random(in: 0.01...100_000)],
                convertedVolume: ["usd": .random(in: 100_000...100_000_000)],
                trustScore: "green",
                bidAskSpreadPercentage: .random(in: 0.01...10),
                timestamp: "2024-02-05T12:00:00Z",
                lastTradedAt: "2024-02-05T12:00:00Z",
                lastFetchAt: "2024-02-05T12:00:00Z",
                isAnomaly: false,
                isStale: false,
                tradeURL: "https://binance.com/trade/BTC_USD",
                tokenInfoURL: nil,
                coinId: "bitcoin",
                targetCoinId: "usd"
            )
        ]
    }
}
