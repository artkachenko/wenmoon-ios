//
//  ContentViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 15.01.25.
//

import XCTest
@testable import WenMoon

class ContentViewModelTests: XCTestCase {
    // MARK: - Properties
    var viewModel: ContentViewModel!
    var coinScannerService: CoinScannerServiceMock!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        coinScannerService = CoinScannerServiceMock()
        viewModel = ContentViewModel(coinScannerService: coinScannerService)
    }
    
    override func tearDown() {
        viewModel = nil
        coinScannerService = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    // Global Crypto Market Data
    func testFetchGlobalCryptoMarketData_success() async throws {
        // Setup
        let globalCryptoMarketData = GlobalCryptoMarketData(
            marketCapPercentage: ["btc": 56.5, "eth": 12.8, "others": 30.7]
        )
        coinScannerService.getGlobalCryptoMarketDataResult = .success(globalCryptoMarketData)
        
        // Action
        await viewModel.fetchGlobalCryptoMarketData()
        
        // Assertions
        let expectedItems = [
            GlobalMarketItem(type: .btcDominance, value: "56,5 %"),
            GlobalMarketItem(type: .ethDominance, value: "12,8 %"),
            GlobalMarketItem(type: .othersDominance, value: "30,7 %")
        ]
        
        for (index, expectedItem) in expectedItems.enumerated() {
            let item = viewModel.globalMarketItems[index]
            XCTAssertEqual(item.type, expectedItem.type)
            XCTAssertEqual(item.value, expectedItem.value)
        }
        
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchGlobalCryptoMarketData_apiError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeAPIError()
        coinScannerService.getGlobalCryptoMarketDataResult = .failure(error)
        
        // Action
        await viewModel.fetchGlobalCryptoMarketData()
        
        // Assertions
        XCTAssertTrue(viewModel.globalMarketItems.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    // Global Market Data
    func testFetchGlobalMarketData_success() async throws {
        // Setup
        let dateFormatter = ISO8601DateFormatter()
        let globalMarketData = GlobalMarketData(
            cpiPercentage: 2.7,
            nextCPIDate: dateFormatter.date(from: "2025-01-01T00:00:00Z")!,
            interestRatePercentage: 4.5,
            nextFOMCMeetingDate: dateFormatter.date(from: "2025-02-01T00:00:00Z")!
        )
        coinScannerService.getGlobalMarketDataResult = .success(globalMarketData)
        
        // Action
        await viewModel.fetchGlobalMarketData()
        
        // Assertions
        let expectedItems = [
            GlobalMarketItem(type: .cpi, value: "2,7 %"),
            GlobalMarketItem(type: .nextCPI, value: "1 Jan 2025"),
            GlobalMarketItem(type: .interestRate, value: "4,5 %"),
            GlobalMarketItem(type: .nextFOMCMeeting, value: "1 Feb 2025")
        ]
        
        for (index, expectedItem) in expectedItems.enumerated() {
            let item = viewModel.globalMarketItems[index]
            XCTAssertEqual(item.type, expectedItem.type)
            XCTAssertEqual(item.value, expectedItem.value)
        }
        
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchGlobalMarketData_apiError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeAPIError()
        coinScannerService.getGlobalMarketDataResult = .failure(error)
        
        // Action
        await viewModel.fetchGlobalMarketData()
        
        // Assertions
        XCTAssertTrue(viewModel.globalMarketItems.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
}
