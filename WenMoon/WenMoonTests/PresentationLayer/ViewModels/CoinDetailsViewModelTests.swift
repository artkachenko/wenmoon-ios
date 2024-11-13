//
//  CoinDetailsViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 11.11.24.
//

import XCTest
@testable import WenMoon

class CoinDetailsViewModelTests: XCTestCase {
    // MARK: - Properties
    var viewModel: CoinDetailsViewModel!
    var service: CoinScannerServiceMock!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        service = CoinScannerServiceMock()
        viewModel = CoinDetailsViewModel(coin: CoinData(), chartData: [:], service: service)
    }
    
    override func tearDown() {
        viewModel = nil
        service = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testFetchChartData_success() async throws {
        // Setup
        let chartData = ChartDataFactoryMock.makeChartDataForTimeframes()
        service.getChartDataResult = .success(chartData)
        
        // Action
        await viewModel.fetchChartData()
        
        // Assertions
        assertChartDataEqual(viewModel.chartData, chartData[Timeframe.oneHour.rawValue]!)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchChartData_usesCache() async throws {
        // Setup
        let cachedChartData = ChartDataFactoryMock.makeChartDataForTimeframes()
        viewModel.chartDataCache = cachedChartData
        
        // Action
        await viewModel.fetchChartData()
        
        // Assertions
        assertChartDataEqual(viewModel.chartData, cachedChartData[Timeframe.oneHour.rawValue]!)
    }
    
    func testFetchChartData_invalidParameterError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeInvalidParameterError()
        service.getChartDataResult = .failure(error)
        
        // Action
        await viewModel.fetchChartData()
        
        // Assertions
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
}
