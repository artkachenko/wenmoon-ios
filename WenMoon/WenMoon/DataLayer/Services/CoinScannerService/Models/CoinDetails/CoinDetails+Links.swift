//
//  CoinDetails+Links.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 14.02.25.
//

import Foundation

extension CoinDetails {
    struct Links: Codable, Equatable {
        struct ReposURL: Codable, Equatable {
            var github: [URL]? = nil
        }
        
        var homepage: [URL]? = nil
        var whitepaper: URL? = nil
        var blockchainSite: [URL]? = nil
        var chatUrl: [URL]? = nil
        var announcementUrl: [URL]? = nil
        var twitterScreenName: String? = nil
        var telegramChannelIdentifier: String? = nil
        var subredditUrl: URL? = nil
        var reposUrl: ReposURL = .init()
    }
}
