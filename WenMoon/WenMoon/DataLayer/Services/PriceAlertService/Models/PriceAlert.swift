//
//  PriceAlert.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 23.05.23.
//

import Foundation

struct PriceAlert: Codable {
    enum TargetDirection: String, Codable {
        case above = "ABOVE"
        case below = "BELOW"
    }

    let coinId: String
    let coinName: String
    let targetPrice: Double
    let targetDirection: TargetDirection
}

extension PriceAlert {
    static let btc = PriceAlert(coinId: "btc",
                                coinName: "Bitcoin",
                                targetPrice: 30000,
                                targetDirection: .above)
    static let eth = PriceAlert(coinId: "eth",
                                coinName: "Ethereum",
                                targetPrice: 1000,
                                targetDirection: .below)
}
