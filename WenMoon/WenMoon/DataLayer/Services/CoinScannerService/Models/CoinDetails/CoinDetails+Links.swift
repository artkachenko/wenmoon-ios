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
            var github: [SafeURL]? = nil
        }
        
        var homepage: [SafeURL]? = nil
        var whitepaper: SafeURL? = nil
        var blockchainSite: [SafeURL]? = nil
        var chatUrl: [SafeURL]? = nil
        var announcementUrl: [SafeURL]? = nil
        var twitterScreenName: String? = nil
        var telegramChannelIdentifier: String? = nil
        var subredditUrl: SafeURL? = nil
        var reposUrl: ReposURL = .init()
    }
}
