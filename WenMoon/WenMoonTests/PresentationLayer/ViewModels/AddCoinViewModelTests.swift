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
    func testFetchCoins_success() async throws {
        // Setup
        let response = CoinFactoryMock.makeCoins()
        service.getCoinsAtPageResult = .success(response)
        
        // Action
        await viewModel.fetchCoins()
        
        // Assertions
        let coins = viewModel.coins
        assertCoinsEqual(coins, response)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchCoins_usesCache() async throws {
        // Setup
        let cachedCoins = CoinFactoryMock.makeCoins()
        viewModel.coinsCache[1] = cachedCoins
        
        // Action
        await viewModel.fetchCoins(at: 1)
        
        // Assertions
        assertCoinsEqual(viewModel.coins, cachedCoins)
    }
    
    func testFetchCoins_networkError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeNoNetworkConnectionError()
        service.getCoinsAtPageResult = .failure(error)
        
        // Action
        await viewModel.fetchCoins()
        
        // Assertions
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    // Search Coins
    func testSearchCoinsByQuery_success() async throws {
        // Setup
        let response = CoinFactoryMock.makeCoins()
        service.searchCoinsByQueryResult = .success(response)
        
        // Action
        await viewModel.searchCoins(for: "bit")
        
        // Assertions
        assertCoinsEqual(viewModel.coins, response)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSearchCoinsByQuery_emptyResult() async throws {
        // Setup
        let response = CoinFactoryMock.makeEmptyCoins()
        service.searchCoinsByQueryResult = .success(response)
        
        // Action
        await viewModel.searchCoins(for: "invalidquery")
        
        // Assertions
        XCTAssert(viewModel.coins.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSearchCoins_usesCache() async throws {
        // Setup
        let cachedCoins = CoinFactoryMock.makeCoins()
        viewModel.searchCoinsCache["bit"] = cachedCoins
        
        // Action
        await viewModel.searchCoins(for: "bit")
        
        // Assertions
        assertCoinsEqual(viewModel.coins, cachedCoins)
    }
    
    func testSearchCoinsByQuery_unknownError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeUnknownError()
        service.searchCoinsByQueryResult = .failure(error)
        
        // Action
        await viewModel.searchCoins(for: "bit")
        
        // Assertions
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testHandleSearchInput_emptyQuery() async throws {
        // Setup
        let initialCoins = CoinFactoryMock.makeCoins()
        service.getCoinsAtPageResult = .success(initialCoins)
        await viewModel.fetchCoins()
        
        // Action
        await viewModel.handleSearchInput("")
        
        // Assertions
        assertCoinsEqual(viewModel.coins, initialCoins)
        XCTAssertNil(viewModel.errorMessage)
    }
}
