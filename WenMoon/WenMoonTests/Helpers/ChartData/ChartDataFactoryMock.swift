//
//  ChartDataFactoryMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 11.11.24.
//

import Foundation
@testable import WenMoon

struct ChartDataFactoryMock {
    static func makeChartData(_ count: Int = 10) -> ChartData {
        let prices = (0..<count).map { index in
            ChartData.Point(
                date: Date().addingTimeInterval(-Double(index) * 86400),
                price: .random(in: 0.01...100_000)
            )
        }
        return ChartData(prices: prices)
    }
}
