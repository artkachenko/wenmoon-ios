//
//  ChartData.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 08.11.24.
//

import Foundation

struct ChartData: Codable, Equatable {
    // MARK: - Properties
    let date: Date
    let price: Double
    
    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case timestamp
        case close
    }
    
    // MARK: - Initializers
    init(date: Date, price: Double) {
        self.date = date
        self.price = price
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let timestamp = try container.decode(Int.self, forKey: .timestamp)
        date = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
        price = try container.decode(Double.self, forKey: .close)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(Int(date.timeIntervalSince1970 * 1000), forKey: .timestamp)
        try container.encode(price, forKey: .close)
    }
}
