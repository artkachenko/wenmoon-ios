//
//  PriceAlert.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 23.05.23.
//

import Foundation

struct PriceAlert: Codable, Hashable {
    enum TargetDirection: String, Codable {
        case above = "ABOVE"
        case below = "BELOW"
        
        var iconName: String {
            switch self {
            case .above:
                return "ArrowIncreaseIcon"
            case .below:
                return "ArrowDecreaseIcon"
            }
        }
    }
    
    let id: String
    let symbol: String
    let targetPrice: Double
    let targetDirection: TargetDirection
}
