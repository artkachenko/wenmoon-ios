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
    var coinScannerService: CoinScannerServiceMock!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        coinScannerService = CoinScannerServiceMock()
        viewModel = CoinDetailsViewModel(
            coin: CoinData(),
            coinScannerService: coinScannerService
        )
    }
    
    override func tearDown() {
        viewModel = nil
        coinScannerService = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    // Coin Details
    func testFetchCoinDetails_success() async {
        // Setup
        let coinDetails = CoinDetailsFactoryMock.makeCoinDetails()
        coinScannerService.getCoinDetailsResult = .success(coinDetails)
        
        // Action
        await viewModel.fetchCoinDetails()
        
        // Assertions
        XCTAssertEqual(viewModel.coinDetails, coinDetails)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFetchCoinDetails_failure() async {
        // Setup
        let error = ErrorFactoryMock.makeAPIError()
        coinScannerService.getCoinDetailsResult = .failure(error)
        
        // Action
        await viewModel.fetchCoinDetails()
        
        // Assertions
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    // Chart Data
    func testFetchChartData_success() async {
        // Setup
        let chartData = ChartDataFactoryMock.makeChartData()
        coinScannerService.getChartDataResult = .success(chartData)
        
        // Action
        await viewModel.fetchChartData()
        
        // Assertions
        assertChartDataEqual(viewModel.chartData, chartData)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchChartData_usesCache() async {
        // Setup
        let cachedChartData = ChartDataFactoryMock.makeChartDataForTimeframes()
        viewModel.chartDataCache = cachedChartData
        
        // Actions & Assertions
        await viewModel.fetchChartData(on: .oneDay)
        assertChartDataEqual(viewModel.chartData, cachedChartData[.oneDay]!)
        
        await viewModel.fetchChartData(on: .oneWeek)
        assertChartDataEqual(viewModel.chartData, cachedChartData[.oneWeek]!)
        
        await viewModel.fetchChartData(on: .oneMonth)
        assertChartDataEqual(viewModel.chartData, cachedChartData[.oneMonth]!)
        
        await viewModel.fetchChartData(on: .yearToDate)
        assertChartDataEqual(viewModel.chartData, cachedChartData[.yearToDate]!)
    }
    
    func testFetchChartData_emptyResponse() async {
        // Setup
        coinScannerService.getChartDataResult = .success([])
        
        // Action
        await viewModel.fetchChartData()
        
        // Assertions
        XCTAssertTrue(viewModel.chartData.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchChartData_invalidParameterError() async {
        // Setup
        let error = ErrorFactoryMock.makeInvalidParameterError()
        coinScannerService.getChartDataResult = .failure(error)
        
        // Action
        await viewModel.fetchChartData()
        
        // Assertions
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
}
