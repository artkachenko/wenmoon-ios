//
//  CoinDetails+Links.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 14.02.25.
//

import Foundation

// MARK: - Links
extension CoinDetails {
    struct Links: Codable, Equatable {
        // MARK: - Properties
        let homepage: [URL]?
        let whitepaper: URL?
        let blockchainSite: [URL]?
        let chatUrl: [URL]?
        let announcementUrl: [URL]?
        let twitterScreenName: String?
        let telegramChannelIdentifier: String?
        let subredditUrl: URL?
        let reposUrl: ReposURL
        
        // MARK: - Initializers
        init(
            homepage: [URL]? = nil,
            whitepaper: URL? = nil,
            blockchainSite: [URL]? = nil,
            chatUrl: [URL]? = nil,
            announcementUrl: [URL]? = nil,
            twitterScreenName: String? = nil,
            telegramChannelIdentifier: String? = nil,
            subredditUrl: URL? = nil,
            reposUrl: ReposURL = .init()
        ) {
            self.homepage = homepage
            self.whitepaper = whitepaper
            self.blockchainSite = blockchainSite
            self.chatUrl = chatUrl
            self.announcementUrl = announcementUrl
            self.twitterScreenName = twitterScreenName
            self.telegramChannelIdentifier = telegramChannelIdentifier
            self.subredditUrl = subredditUrl
            self.reposUrl = reposUrl
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            homepage = try container.decodeIfPresent([SafeURL].self, forKey: .homepage)?.compactMap { $0.url }
            whitepaper = try container.decodeIfPresent(SafeURL.self, forKey: .whitepaper)?.url
            blockchainSite = try container.decodeIfPresent([SafeURL].self, forKey: .blockchainSite)?.compactMap { $0.url }
            chatUrl = try container.decodeIfPresent([SafeURL].self, forKey: .chatUrl)?.compactMap { $0.url }
            announcementUrl = try container.decodeIfPresent([SafeURL].self, forKey: .announcementUrl)?.compactMap { $0.url }
            twitterScreenName = try container.decodeIfPresent(String.self, forKey: .twitterScreenName)
            telegramChannelIdentifier = try container.decodeIfPresent(String.self, forKey: .telegramChannelIdentifier)
            subredditUrl = try container.decodeIfPresent(SafeURL.self, forKey: .subredditUrl)?.url
            reposUrl = try container.decodeIfPresent(ReposURL.self, forKey: .reposUrl) ?? ReposURL()
        }
    }
}

// MARK: - ReposURL
extension CoinDetails.Links {
    struct ReposURL: Codable, Equatable {
        // MARK: - Properties
        let github: [URL]?
        
        // MARK: - Initializers
        init(github: [URL]? = nil) {
            self.github = github
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            github = try container.decodeIfPresent([SafeURL].self, forKey: .github)?.compactMap { $0.url }
        }
    }
}
