//
//  CoinScannerServiceTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.04.23.
//

import XCTest
@testable import WenMoon

class CoinScannerServiceTests: XCTestCase {
    // MARK: - Properties
    var service: CoinScannerService!
    var httpClient: HTTPClientMock!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        httpClient = HTTPClientMock()
        service = CoinScannerServiceImpl(httpClient: httpClient)
    }
    
    override func tearDown() {
        service = nil
        httpClient = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    // Get Coins
    func testGetCoinsAtPage_success() async throws {
        // Setup
        let response = CoinFactoryMock.makeCoins()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        // Action
        let coins = try await service.getCoins(at: 1)
        
        // Assertions
        assertCoinsEqual(coins, response)
    }
    
    func testGetCoinsAtPage_apiError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeAPIError()
        httpClient.getResponse = .failure(error)
        
        // Action & Assertions
        await assertFailure(
            for: { [weak self] in
                try await self!.service.getCoins(at: 1)
            },
            expectedError: error
        )
    }
    
    func testGetCoinsByIDs_success() async throws {
        // Setup
        let response = CoinFactoryMock.makeCoins()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        // Action
        let coins = try await service.getCoins(by: [])
        
        // Assertions
        assertCoinsEqual(coins, response)
    }
    
    func testGetCoinsByIDs_invalidEndpoint() async throws {
        // Setup
        let error = ErrorFactoryMock.makeInvalidEndpointError()
        httpClient.getResponse = .failure(error)
        
        // Action & Assertions
        await assertFailure(
            for: { [weak self] in
                try await self!.service.getCoins(by: [])
            },
            expectedError: error
        )
    }
    
    // Search Coins
    func testSearchCoinsByQuery_success() async throws {
        // Setup
        let response = CoinFactoryMock.makeCoins()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        // Action
        let coins = try await service.searchCoins(by: "")
        
        // Assertions
        assertCoinsEqual(coins, response)
    }
    
    func testSearchCoinsByQuery_emptyResult() async throws {
        // Setup
        let response = [Coin]()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        // Action
        let coins = try await service.searchCoins(by: "")
        
        // Assertions
        XCTAssert(coins.isEmpty)
    }
    
    func testSearchCoinsByQuery_networkError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeNoNetworkConnectionError()
        httpClient.getResponse = .failure(error)
        
        // Action & Assertions
        await assertFailure(
            for: { [weak self] in
                try await self!.service.searchCoins(by: "")
            },
            expectedError: error
        )
    }
    
    // Get Market Data
    func testGetMarketDataForCoins_success() async throws {
        // Setup
        let ids = CoinFactoryMock.makeCoins().map { $0.id }
        let response = MarketDataFactoryMock.makeMarketData()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        // Action
        let marketData = try await service.getMarketData(for: ids)
        
        // Assertions
        assertMarketDataEqual(marketData, response, for: ids)
    }
    
    func testGetMarketDataForCoins_decodingError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeFailedToDecodeResponseError()
        httpClient.getResponse = .failure(error)
        
        // Action & Assertions
        await assertFailure(
            for: { [weak self] in
                try await self!.service.getMarketData(for: [])
            },
            expectedError: error
        )
    }
    
    // Get Chart Data
    func testGetChartData_success() async throws {
        // Setup
        let response = ChartDataFactoryMock.makeChartDataForTimeframes()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        // Action
        let chartData = try await service.getChartData(for: "", currency: .usd)
        
        // Assertions
        assertChartDataForTimeframesEqual(chartData, response)
    }
    
    func testGetChartData_invalidParameter() async throws {
        // Setup
        let error = ErrorFactoryMock.makeInvalidParameterError()
        httpClient.getResponse = .failure(error)
        
        // Action & Assertions
        await assertFailure(
            for: { [weak self] in
                try await self!.service.getChartData(for: "", currency: .usd)
            },
            expectedError: error
        )
    }
    
    // Get Global Crypto Market Data
    func testGetGlobalCryptoMarketData_success() async throws {
        // Setup
        let response = GlobalCryptoMarketData(
            marketCapPercentage: ["btc": 56.5, "eth": 12.8, "others": 30.7]
        )
        httpClient.getResponse = .success(try! JSONEncoder().encode(response))
        
        // Action
        let data = try await service.getGlobalCryptoMarketData()
        
        // Assertions
        XCTAssertEqual(data.marketCapPercentage, response.marketCapPercentage)
    }

    func testGetGlobalCryptoMarketData_networkError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeNoNetworkConnectionError()
        httpClient.getResponse = .failure(error)
        
        // Action & Assertions
        await assertFailure(
            for: { [weak self] in
                try await self!.service.getGlobalCryptoMarketData()
            },
            expectedError: error
        )
    }

    // Get Global Market Data
    func testGetGlobalMarketData_success() async throws {
        // Setup
        let dateFormatter = ISO8601DateFormatter()
        let response = GlobalMarketData(
            cpiPercentage: 2.7,
            nextCPIDate: dateFormatter.date(from: "2025-01-01T00:00:00Z")!,
            interestRatePercentage: 4.5,
            nextFOMCMeetingDate: dateFormatter.date(from: "2025-02-01T00:00:00Z")!
        )
        httpClient.getResponse = .success(try! JSONEncoder().encode(response))
        
        // Action
        let data = try await service.getGlobalMarketData()
        
        // Assertions
        XCTAssertEqual(data.cpiPercentage, response.cpiPercentage)
        XCTAssertEqual(data.nextCPIDate, response.nextCPIDate)
        XCTAssertEqual(data.interestRatePercentage, response.interestRatePercentage)
        XCTAssertEqual(data.nextFOMCMeetingDate, response.nextFOMCMeetingDate)
    }

    func testGetGlobalMarketData_decodingError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeFailedToDecodeResponseError()
        httpClient.getResponse = .failure(error)
        
        // Action & Assertions
        await assertFailure(
            for: { [weak self] in
                try await self!.service.getGlobalMarketData()
            },
            expectedError: error
        )
    }
}
