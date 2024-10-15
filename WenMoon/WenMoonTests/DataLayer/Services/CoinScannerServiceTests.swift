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
    func testGetCoinsSuccess() async throws {
        let response = makeCoins()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        let coins = try await service.getCoins(at: 1)
        
        XCTAssertFalse(coins.isEmpty)
        XCTAssertEqual(coins.count, response.count)
        
        assertCoin(coins.first!, response.first!)
        assertCoin(coins.last!, response.last!)
    }
    
    func testGetCoinsFailure() async throws {
        let apiError = makeAPIError()
        httpClient.getResponse = .failure(apiError)
        
        await assertAPIFailure(
            for: { [weak self] in
                try await self?.service.getCoins(at: 1)
            },
            expectedError: apiError
        )
    }
    
    // Search Coins
    func testSearchCoinsByQuerySuccess() async throws {
        let response = makeCoins()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        let coins = try await service.searchCoins(by: "bit")
        
        XCTAssertFalse(coins.isEmpty)
        XCTAssertEqual(coins.count, response.count)
        
        assertCoin(coins.first!, response.first!)
        assertCoin(coins.last!, response.last!)
    }
    
    func testSearchCoinsByQueryEmptyResult() async throws {
        let response = [Coin]()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        let coins = try await service.searchCoins(by: "sdfghjkl")
        XCTAssertTrue(coins.isEmpty)
    }
    
    func testSearchCoinsByQueryFailure() async throws {
        let apiError = makeAPIError()
        httpClient.getResponse = .failure(apiError)
        
        await assertAPIFailure(
            for: { [weak self] in
                try await self?.service.searchCoins(by: "bit")
            },
            expectedError: apiError
        )
    }
    
    // Get Market Data
    func testGetMarketDataForCoins() async throws {
        let coinIDs = makeCoins().map { $0.id }
        let response = makeMarketData()
        httpClient.getResponse = .success(try! httpClient.encoder.encode(response))
        
        let result = try await service.getMarketData(for: coinIDs)
        
        XCTAssertFalse(result.isEmpty)
        XCTAssertEqual(result.count, response.count)
        
        let firstCoinID = coinIDs.first!
        XCTAssertEqual(result[firstCoinID]!.currentPrice, response[firstCoinID]!.currentPrice)
        XCTAssertEqual(result[firstCoinID]!.priceChange, response[firstCoinID]!.priceChange)
        
        let lastCoinID = coinIDs.last!
        XCTAssertEqual(result[lastCoinID]!.currentPrice, response[lastCoinID]!.currentPrice)
        XCTAssertEqual(result[lastCoinID]!.priceChange, response[lastCoinID]!.priceChange)
    }
    
    func testGetMarketDataForCoinsFailure() async throws {
        let coinIDs = makeCoins().map { $0.id }
        let apiError = makeAPIError()
        httpClient.getResponse = .failure(apiError)
        
        await assertAPIFailure(
            for: { [weak self] in
                try await self?.service.getMarketData(for: coinIDs)
            },
            expectedError: apiError
        )
    }
}
