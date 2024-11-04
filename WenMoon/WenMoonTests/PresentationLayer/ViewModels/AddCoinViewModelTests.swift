//
//  AddCoinViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.04.23.
//

import XCTest
@testable import WenMoon

class AddCoinViewModelTests: XCTestCase {
    // MARK: - Properties
    var viewModel: AddCoinViewModel!
    var service: CoinScannerServiceMock!
    var swiftDataManager: SwiftDataManagerMock!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        service = CoinScannerServiceMock()
        swiftDataManager = SwiftDataManagerMock()
        viewModel = AddCoinViewModel(coinScannerService: service, swiftDataManager: swiftDataManager)
    }
    
    override func tearDown() {
        viewModel = nil
        service = nil
        swiftDataManager = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    // Fetch Coins
    func testFetchCoins_success() async throws {
        // Setup
        let coins = CoinFactoryMock.makeCoins()
        service.getCoinsAtPageResult = .success(coins)
        
        // Action
        await viewModel.fetchCoins()
        
        // Assertions
        assertCoinsEqual(viewModel.coins, coins)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchCoins_nextPage() async throws {
        // Setup
        let firstPageCoins = CoinFactoryMock.makeCoins()
        let secondPageCoins = CoinFactoryMock.makeCoins(at: 2)
        service.getCoinsAtPageResult = .success(firstPageCoins)
        await viewModel.fetchCoins()
        service.getCoinsAtPageResult = .success(secondPageCoins)
        
        // Action
        await viewModel.fetchCoinsOnNextPageIfNeeded(firstPageCoins.last!)
        
        // Assertions
        XCTAssertEqual(viewModel.currentPage, 2)
        assertCoinsEqual(viewModel.coins, firstPageCoins + secondPageCoins)
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
        let coins = CoinFactoryMock.makeCoins()
        service.searchCoinsByQueryResult = .success(coins)
        
        // Action
        await viewModel.searchCoins(for: "")
        
        // Assertions
        assertCoinsEqual(viewModel.coins, coins)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSearchCoinsByQuery_emptyResult() async throws {
        // Setup
        service.searchCoinsByQueryResult = .success([])
        
        // Action
        await viewModel.searchCoins(for: "")
        
        // Assertions
        XCTAssert(viewModel.coins.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSearchCoins_usesCache() async throws {
        // Setup
        let cachedCoins = CoinFactoryMock.makeCoins()
        viewModel.searchCoinsCache[""] = cachedCoins
        viewModel.isInSearchMode = true
        
        // Action
        await viewModel.searchCoins(for: "")
        
        // Assertions
        assertCoinsEqual(viewModel.coins, cachedCoins)
    }
    
    func testSearchCoins_cachesResult() async throws {
        // Setup
        let coins = CoinFactoryMock.makeCoins()
        service.searchCoinsByQueryResult = .success(coins)
        
        // Action
        await viewModel.searchCoins(for: "")
        
        // Assertions
        XCTAssertEqual(viewModel.searchCoinsCache[""], coins)
    }
    
    func testSearchCoinsByQuery_decodingError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeFailedToDecodeResponseError()
        service.searchCoinsByQueryResult = .failure(error)
        
        // Action
        await viewModel.searchCoins(for: "")
        
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
    
    func testFetchSavedCoins_success() async throws {
        // Setup
        let mockCoins = CoinFactoryMock.makeCoins()
        for coin in mockCoins {
            let newCoin = CoinFactoryMock.makeCoinData(from: coin)
            swiftDataManager.fetchResult.append(newCoin)
        }
        
        // Action
        viewModel.fetchSavedCoins()
        
        // Assertions
        XCTAssert(swiftDataManager.fetchMethodCalled)
        XCTAssertEqual(viewModel.savedCoinIDs, Set(mockCoins.map(\.id)))
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchSavedCoins_fetchError() async throws {
        // Setup
        let error: SwiftDataError = .failedToFetchModels
        swiftDataManager.swiftDataError = error
        
        // Action
        viewModel.fetchSavedCoins()
        
        // Assertions
        XCTAssert(swiftDataManager.fetchMethodCalled)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testToggleCoinSaveState() {
        // Setup
        let coin = CoinFactoryMock.makeCoin()
        
        // Toggle save state on
        viewModel.toggleSaveState(for: coin)
        XCTAssert(viewModel.isCoinSaved(coin))
        
        // Toggle save state off
        viewModel.toggleSaveState(for: coin)
        XCTAssertFalse(viewModel.isCoinSaved(coin))
    }
}
