//
//  ChartData.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 08.11.24.
//

import Foundation

struct ChartData: Codable, Equatable {
    struct ChartDataPoint: Codable, Equatable {
        let date: Date
        let price: Double
        
        init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            let timestamp = try container.decode(Int.self)
            self.date = Date(timeIntervalSince1970: TimeInterval(timestamp / 1000))
            self.price = try container.decode(Double.self)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.unkeyedContainer()
            try container.encode(Int(date.timeIntervalSince1970 * 1000))
            try container.encode(price)
        }
    }
    
    let prices: [ChartDataPoint]
}
