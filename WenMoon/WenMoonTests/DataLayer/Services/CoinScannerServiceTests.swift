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
        service = CoinScannerServiceImpl(httpClient: httpClient, baseURL: URL(string: "https://example.com/")!)
    }
    
    override func tearDown() {
        service = nil
        httpClient = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    // Get Coins
    func testGetCoins_success() async throws {
        // Setup
        let response = CoinFactoryMock.makeCoins()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        // Action
        let coins = try await service.getCoins(at: 1)
        
        // Assertions
        assertCoinsEqual(coins, response)
    }
    
    func testGetCoins_apiError() async throws {
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
    
    // Search Coins
    func testSearchCoinsByQuery_success() async throws {
        // Setup
        let response = CoinFactoryMock.makeCoins()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        // Action
        let coins = try await service.searchCoins(by: "bit")
        
        // Assertions
        assertCoinsEqual(coins, response)
    }
    
    func testSearchCoinsByQuery_emptyResult() async throws {
        // Setup
        let response = [Coin]()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        // Action
        let coins = try await service.searchCoins(by: "sdfghjkl")
        
        // Assertions
        XCTAssert(coins.isEmpty)
    }
    
    func testSearchCoinsByQuery_invalidEndpoint() async throws {
        // Setup
        let error = ErrorFactoryMock.makeInvalidEndpointError()
        httpClient.getResponse = .failure(error)
        
        // Action & Assertions
        await assertFailure(
            for: { [weak self] in
                try await self!.service.searchCoins(by: "bit")
            },
            expectedError: error
        )
    }
    
    // Get Market Data
    func testGetMarketDataForCoins_success() async throws {
        // Setup
        let coinIDs = CoinFactoryMock.makeCoins().map { $0.id }
        let response = MarketDataFactoryMock.makeMarketData()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        // Action
        let marketData = try await service.getMarketData(for: coinIDs)
        
        // Assertions
        assertMarketDataEqual(marketData, response, for: coinIDs)
    }
    
    func testGetMarketDataForCoins_networkError() async throws {
        // Setup
        let coinIDs = CoinFactoryMock.makeCoins().map { $0.id }
        let error = ErrorFactoryMock.makeNoNetworkConnectionError()
        httpClient.getResponse = .failure(error)
        
        // Action & Assertions
        await assertFailure(
            for: { [weak self] in
                try await self!.service.getMarketData(for: coinIDs)
            },
            expectedError: error
        )
    }
}
