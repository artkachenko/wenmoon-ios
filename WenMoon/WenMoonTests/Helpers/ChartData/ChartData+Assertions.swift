//
//  ChartData+Assertions.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 11.11.24.
//

import Foundation
import XCTest
@testable import WenMoon

func assertChartDataEqual(_ chartData: ChartData, _ expectedChartData: ChartData) {
    XCTAssertEqual(chartData.prices.count, expectedChartData.prices.count)
    for (index, _) in chartData.prices.enumerated() {
        let point = chartData.prices[index]
        let expectedPoint = expectedChartData.prices[index]
        XCTAssertEqual(point.date.timeIntervalSince1970, expectedPoint.date.timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(point.price, expectedPoint.price)
    }
}
