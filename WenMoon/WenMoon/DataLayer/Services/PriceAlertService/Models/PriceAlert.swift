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
