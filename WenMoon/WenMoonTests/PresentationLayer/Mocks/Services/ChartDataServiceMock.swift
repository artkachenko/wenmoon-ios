//
//  ChartDataServiceMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 11.11.24.
//

import XCTest
@testable import WenMoon

class ChartDataServiceMock: ChartDataService {
    // MARK: - Properties
    var getChartDataResult: Result<ChartData, APIError>!
    
    // MARK: - CoinScannerService
    func getChartData(for id: String, currency: String, timeframe: ChartTimeframe) async throws -> ChartData {
        switch getChartDataResult {
        case .success(let chartData):
            return chartData
        case .failure(let error):
            throw error
        case .none:
            XCTFail("getChartDataResult not set")
            throw APIError.unknown(response: URLResponse())
        }
    }
}
