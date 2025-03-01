//
//  NewsFactoryMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 01.03.25.
//

import Foundation
@testable import WenMoon

struct NewsFactoryMock {
    static func makeAllNews() -> AllNews {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss Z"
        return AllNews(
            coindesk: [
                News(
                    title: "CoinDesk Bitcoin Dip",
                    description: "Bitdeer buys the Bitcoin dip",
                    date: formatter.date(from: "Fri, 28 Feb 2025 15:07:32 +0000")!
                ),
                News(
                    title: "CoinDesk Solana Futures",
                    description: "CME launches Solana futures",
                    date: formatter.date(from: "Fri, 28 Feb 2025 14:28:27 +0000")!
                )
            ],
            cointelegraph: [
                News(
                    title: "CoinTelegraph Bitcoin DCA Zone",
                    description: "Bitcoin hits optimal DCA zone",
                    date: formatter.date(from: "Fri, 28 Feb 2025 16:05:08 +0000")!
                )
            ],
            cryptopotato: [
                News(
                    title: "CryptoPotato Meme Coins",
                    description: "SEC confirms meme coins not securities",
                    date: formatter.date(from: "Fri, 28 Feb 2025 15:58:54 +0000")!
                )
            ],
            bitcoinmagazine: [
                News(
                    title: "BitcoinMag Stablecoins Focus",
                    description: "Senate discusses stablecoins",
                    date: formatter.date(from: "Thu, 27 Feb 2025 01:08:37 +0000")!
                )
            ],
            bitcoinist: [
                News(
                    title: "Bitcoinist Bitcoin Correlation",
                    description: "Bitcoin correlates with S&P 500",
                    date: formatter.date(from: "Fri, 28 Feb 2025 16:00:14 +0000")!
                )
            ]
        )
    }
}
