//
//  AllNews.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 01.03.25.
//

import Foundation

struct AllNews: Codable, Equatable {
    let coindesk: [News]?
    let cointelegraph: [News]?
    let cryptopotato: [News]?
    let bitcoinmagazine: [News]?
    let bitcoinist: [News]?
}
