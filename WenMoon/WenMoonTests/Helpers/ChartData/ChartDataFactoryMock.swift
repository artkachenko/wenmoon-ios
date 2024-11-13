//
//  ChartDataFactoryMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 11.11.24.
//

import Foundation
@testable import WenMoon

struct ChartDataFactoryMock {
    static func makeChartDataForTimeframes(_ timeframes: [Timeframe] = Timeframe.allCases) -> [String: [ChartData]] {
        var data: [String: [ChartData]] = [:]
        for timeframe in timeframes {
            data[timeframe.rawValue] = makeChartData()
        }
        return data
    }
    
    static func makeChartData(_ count: Int = 10) -> [ChartData] {
        (0..<count).map { index in
            ChartData(
                date: Date().addingTimeInterval(-Double(index) * 86400),
                price: .random(in: 0.01...100_000)
            )
        }
    }
}
