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
    var service: ChartDataServiceMock!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        service = ChartDataServiceMock()
        viewModel = CoinDetailsViewModel(coin: CoinData(), chartDataService: service)
    }
    
    override func tearDown() {
        viewModel = nil
        service = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testFetchChartData_success() async throws {
        // Setup
        let chartData = ChartDataFactoryMock.makeChartData()
        service.getChartDataResult = .success(chartData)
        
        // Action
        await viewModel.fetchChartData()
        
        // Assertions
        assertChartDataEqual(viewModel.chartData!, chartData)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchChartData_usesCache() async throws {
        // Setup
        let cachedChartData = ChartDataFactoryMock.makeChartData()
        viewModel.chartDataCache[.oneDay] = cachedChartData
        
        // Action
        await viewModel.fetchChartData()
        
        // Assertions
        assertChartDataEqual(viewModel.chartData!, cachedChartData)
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
