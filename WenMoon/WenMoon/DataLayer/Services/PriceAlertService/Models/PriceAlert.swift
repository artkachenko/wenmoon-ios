//
//  PriceAlert.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 23.05.23.
//

import SwiftUI

struct PriceAlert: Codable, Hashable {
    // MARK: - Nested Types
    enum TargetDirection: String, Codable {
        case above = "ABOVE"
        case below = "BELOW"
        
        var iconName: String {
            switch self {
            case .above: return "arrow.increase"
            case .below: return "arrow.decrease"
            }
        }
        
        var color: Color {
            switch self {
            case .above: return .neonGreen
            case .below: return .neonPink
            }
        }
    }
    
    // MARK: - Properties
    let id: String
    let coinID: String
    let symbol: String
    let targetPrice: Double
    let targetDirection: TargetDirection
    var isActive: Bool
    
    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id
        case coinID = "coinId"
        case symbol
        case targetPrice
        case targetDirection
        case isActive
    }
}
