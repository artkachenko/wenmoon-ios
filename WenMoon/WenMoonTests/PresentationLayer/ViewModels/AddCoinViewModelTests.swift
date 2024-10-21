//
//  AddCoinViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.04.23.
//

import XCTest
@testable import WenMoon

@MainActor
class AddCoinViewModelTests: XCTestCase {
    
    // MARK: - Properties
    var viewModel: AddCoinViewModel!
    var service: CoinScannerServiceMock!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        service = CoinScannerServiceMock()
        viewModel = AddCoinViewModel(coinScannerService: service)
    }
    
    override func tearDown() {
        viewModel = nil
        service = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    // Fetch Coins
    func testFetchCoinsSuccess() async throws {
        let response = makeCoins()
        service.getCoinsAtPageResult = .success(response)
        
        await viewModel.fetchCoins()
        
        let coins = viewModel.coins
        XCTAssertFalse(coins.isEmpty)
        XCTAssertEqual(coins.count, response.count)
        
        assertCoin(coins.first!, response.first!)
        assertCoin(coins.last!, response.last!)
        
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchCoinsUsesCache() async throws {
        let cachedCoins = makeCoins()
        viewModel.coinsCache[1] = cachedCoins
        
        await viewModel.fetchCoins(at: 1)
        
        let coins = viewModel.coins
        XCTAssertEqual(coins.count, cachedCoins.count)
        assertCoin(coins.first!, cachedCoins.first!)
        assertCoin(coins.last!, cachedCoins.last!)
    }
    
    func testFetchCoinsFailure() async throws {
        let apiError: APIError = .apiError(description: "Mocked server error")
        service.getCoinsAtPageResult = .failure(apiError)
        
        await viewModel.fetchCoins()
        
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, apiError.errorDescription)
    }
    
    // Search Coins
    func testSearchCoinsByQuerySuccess() async throws {
        let response = makeCoins()
        service.searchCoinsByQueryResult = .success(response)
        
        await viewModel.searchCoins(for: "bit")
        
        let coins = viewModel.coins
        XCTAssertFalse(coins.isEmpty)
        XCTAssertEqual(coins.count, response.count)
        
        assertCoin(coins.first!, response.first!)
        assertCoin(coins.last!, response.last!)
        
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSearchCoinsByQueryEmptyResult() async throws {
        let response = makeEmptyCoins()
        service.searchCoinsByQueryResult = .success(response)
        
        await viewModel.searchCoins(for: "sdfghjkl")
        
        XCTAssertTrue(viewModel.coins.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSearchCoinsUsesCache() async throws {
        let cachedCoins = makeCoins()
        viewModel.searchCoinsCache["bit"] = cachedCoins
        
        await viewModel.searchCoins(for: "bit")
        
        let coins = viewModel.coins
        XCTAssertEqual(coins.count, cachedCoins.count)
        assertCoin(coins.first!, cachedCoins.first!)
        assertCoin(coins.last!, cachedCoins.last!)
    }
    
    func testHandleSearchInputEmptyQuery() async throws {
        let initialCoins = makeCoins()
        service.getCoinsAtPageResult = .success(initialCoins)
        await viewModel.fetchCoins()
        
        await viewModel.handleSearchInput("")
        
        let coins = viewModel.coins
        XCTAssertEqual(coins.count, initialCoins.count)
        assertCoin(coins.first!, initialCoins.first!)
        assertCoin(coins.last!, initialCoins.last!)
    }
}
