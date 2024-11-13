//
//  ChartData+Assertions.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 11.11.24.
//

import Foundation
import XCTest
@testable import WenMoon

func assertChartDataForTimeframesEqual(_ chartData: [String: [ChartData]], _ expectedChartData: [String: [ChartData]]) {
    XCTAssertEqual(chartData.keys.count, expectedChartData.keys.count)
    
    for (timeframe, expectedData) in expectedChartData {
        let actualData = chartData[timeframe]!
        assertChartDataEqual(actualData, expectedData)
    }
}

func assertChartDataEqual(_ chartData: [ChartData], _ expectedChartData: [ChartData]) {
    XCTAssertEqual(chartData.count, expectedChartData.count)
    for (index, actualPoint) in chartData.enumerated() {
        let expectedPoint = expectedChartData[index]
        XCTAssertEqual(actualPoint.date.timeIntervalSince1970, expectedPoint.date.timeIntervalSince1970, accuracy: 1)
        XCTAssertEqual(actualPoint.price, expectedPoint.price)
    }
}
