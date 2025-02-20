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
    func testFetchAllGlobalMarketData_success() async throws {
        // Setup
        let fearAndGreedIndex = FearAndGreedIndex(data: [.init(value: "75", valueClassification: "Greed")])
        let globalCryptoMarketData = GlobalCryptoMarketData(marketCapPercentage: ["btc": 56.5, "eth": 12.8, "usdt": 2.63])
        let dateFormatter = ISO8601DateFormatter()
        let globalMarketData = GlobalMarketData(
            cpiPercentage: 2.7,
            nextCPIDate: dateFormatter.date(from: "2025-01-01T00:00:00Z")!,
            interestRatePercentage: 4.5,
            nextFOMCMeetingDate: dateFormatter.date(from: "2025-02-01T00:00:00Z")!
        )
        coinScannerService.getFearAndGreedIndexResult = .success(fearAndGreedIndex)
        coinScannerService.getGlobalCryptoMarketDataResult = .success(globalCryptoMarketData)
        coinScannerService.getGlobalMarketDataResult = .success(globalMarketData)
        
        // Action
        await viewModel.fetchAllGlobalMarketData()
        
        // Assertions
        let expectedItems = [
            GlobalMarketDataItem(type: .fearAndGreedIndex, value: "75 Greed"),
            GlobalMarketDataItem(type: .btcDominance, value: "56,5 %"),
            GlobalMarketDataItem(type: .cpi, value: "2,7 %"),
            GlobalMarketDataItem(type: .nextCPI, value: "1 Jan 2025"),
            GlobalMarketDataItem(type: .interestRate, value: "4,5 %"),
            GlobalMarketDataItem(type: .nextFOMCMeeting, value: "1 Feb 2025")
        ]
        assertGlobalMarketItemsEqual(viewModel.globalMarketDataItems, expectedItems)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchAllGlobalMarketData_apiError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeAPIError()
        let fearAndGreedIndex = FearAndGreedIndex(data: [.init(value: "75", valueClassification: "Greed")])
        let globalMarketData = GlobalMarketData(
            cpiPercentage: 2.7,
            nextCPIDate: Date(),
            interestRatePercentage: 4.5,
            nextFOMCMeetingDate: Date()
        )
        coinScannerService.getFearAndGreedIndexResult = .success(fearAndGreedIndex)
        coinScannerService.getGlobalCryptoMarketDataResult = .failure(error)
        coinScannerService.getGlobalMarketDataResult = .success(globalMarketData)
        
        // Action
        await viewModel.fetchAllGlobalMarketData()
        
        // Assertions
        XCTAssertTrue(viewModel.globalMarketDataItems.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testFetchAllGlobalMarketData_missingFearAndGreedData() async throws {
        // Setup
        let fearAndGreedIndex = FearAndGreedIndex(data: [])
        let globalCryptoMarketData = GlobalCryptoMarketData(marketCapPercentage: ["btc": 56.5])
        let globalMarketData = GlobalMarketData(
            cpiPercentage: 2.7,
            nextCPIDate: Date(),
            interestRatePercentage: 4.5,
            nextFOMCMeetingDate: Date()
        )
        coinScannerService.getFearAndGreedIndexResult = .success(fearAndGreedIndex)
        coinScannerService.getGlobalCryptoMarketDataResult = .success(globalCryptoMarketData)
        coinScannerService.getGlobalMarketDataResult = .success(globalMarketData)
        
        // Action
        await viewModel.fetchAllGlobalMarketData()
        
        // Assertions
        XCTAssertTrue(viewModel.globalMarketDataItems.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchAllGlobalMarketData_missingBTCDominance() async throws {
        // Setup
        let fearAndGreedIndex = FearAndGreedIndex(data: [.init(value: "75", valueClassification: "Greed")])
        let globalCryptoMarketData = GlobalCryptoMarketData(marketCapPercentage: ["eth": 12.8])
        let globalMarketData = GlobalMarketData(
            cpiPercentage: 2.7,
            nextCPIDate: Date(),
            interestRatePercentage: 4.5,
            nextFOMCMeetingDate: Date()
        )
        coinScannerService.getFearAndGreedIndexResult = .success(fearAndGreedIndex)
        coinScannerService.getGlobalCryptoMarketDataResult = .success(globalCryptoMarketData)
        coinScannerService.getGlobalMarketDataResult = .success(globalMarketData)
        
        // Action
        await viewModel.fetchAllGlobalMarketData()
        
        // Assertions
        XCTAssertTrue(viewModel.globalMarketDataItems.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // MARK: - Helpers
    private func assertGlobalMarketItemsEqual(_ actual: [GlobalMarketDataItem], _ expected: [GlobalMarketDataItem]) {
        XCTAssertEqual(actual.count, expected.count)
        for (index, expectedItem) in expected.enumerated() {
            let item = actual[index]
            XCTAssertEqual(item.type, expectedItem.type)
            XCTAssertEqual(item.value, expectedItem.value)
        }
    }
}
