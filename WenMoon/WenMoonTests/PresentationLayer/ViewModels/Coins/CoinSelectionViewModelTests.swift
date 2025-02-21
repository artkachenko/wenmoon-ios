//
//  CoinSelectionViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.04.23.
//

import XCTest
@testable import WenMoon

class CoinSelectionViewModelTests: XCTestCase {
    // MARK: - Properties
    var viewModel: CoinSelectionViewModel!
    var service: CoinScannerServiceMock!
    var swiftDataManager: SwiftDataManagerMock!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        service = CoinScannerServiceMock()
        swiftDataManager = SwiftDataManagerMock()
        viewModel = CoinSelectionViewModel(coinScannerService: service, swiftDataManager: swiftDataManager)
    }
    
    override func tearDown() {
        viewModel = nil
        service = nil
        swiftDataManager = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    // Fetch Coins
    func testFetchCoins_success() async {
        // Setup
        let coins = CoinFactoryMock.makeCoins()
        service.getCoinsAtPageResult = .success(coins)
        
        // Action
        await viewModel.fetchCoins()
        
        // Assertions
        assertCoinsEqual(viewModel.coins, coins)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchCoins_nextPage() async {
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
    
    func testFetchCoins_usesCache() async {
        // Setup
        let cachedCoins = CoinFactoryMock.makeCoins()
        viewModel.coinsCache[1] = cachedCoins
        
        // Action
        await viewModel.fetchCoins(at: 1)
        
        // Assertions
        assertCoinsEqual(viewModel.coins, cachedCoins)
    }
    
    func testFetchCoins_networkError() async {
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
    func testSearchCoinsByQuery_success() async {
        // Setup
        let coins = CoinFactoryMock.makeCoins()
        service.searchCoinsByQueryResult = .success(coins)
        
        // Action
        await viewModel.searchCoins(for: "")
        
        // Assertions
        assertCoinsEqual(viewModel.coins, coins)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSearchCoinsByQuery_emptyResult() async {
        // Setup
        service.searchCoinsByQueryResult = .success([])
        
        // Action
        await viewModel.searchCoins(for: "")
        
        // Assertions
        XCTAssertTrue(viewModel.coins.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSearchCoins_usesCache() async {
        // Setup
        let cachedCoins = CoinFactoryMock.makeCoins()
        viewModel.searchCoinsCache[""] = cachedCoins
        viewModel.isInSearchMode = true
        
        // Action
        await viewModel.searchCoins(for: "")
        
        // Assertions
        assertCoinsEqual(viewModel.coins, cachedCoins)
    }
    
    func testSearchCoins_cachesResult() async {
        // Setup
        let coins = CoinFactoryMock.makeCoins()
        service.searchCoinsByQueryResult = .success(coins)
        
        // Action
        await viewModel.searchCoins(for: "")
        
        // Assertions
        XCTAssertEqual(viewModel.searchCoinsCache[""], coins)
    }
    
    func testSearchCoinsByQuery_decodingError() async {
        // Setup
        let error = ErrorFactoryMock.makeFailedToDecodeResponseError()
        service.searchCoinsByQueryResult = .failure(error)
        
        // Action
        await viewModel.searchCoins(for: "")
        
        // Assertions
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testHandleSearchInput_emptyQuery() async {
        // Setup
        let initialCoins = CoinFactoryMock.makeCoins()
        service.getCoinsAtPageResult = .success(initialCoins)
        await viewModel.fetchCoins()
        
        // Action
        await viewModel.handleQueryChange("")
        
        // Assertions
        assertCoinsEqual(viewModel.coins, initialCoins)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchSavedCoins_success() {
        // Setup
        let mockCoins = CoinFactoryMock.makeCoinsData()
        swiftDataManager.fetchResult = mockCoins
        
        // Action
        viewModel.fetchSavedCoins()
        
        // Assertions
        XCTAssertTrue(swiftDataManager.fetchMethodCalled)
        XCTAssertEqual(viewModel.savedCoinIDs, Set(mockCoins.map(\.id)))
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchSavedCoins_fetchError() {
        // Setup
        let error: SwiftDataError = .failedToFetchModels
        swiftDataManager.swiftDataError = error
        
        // Action
        viewModel.fetchSavedCoins()
        
        // Assertions
        XCTAssertTrue(swiftDataManager.fetchMethodCalled)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testToggleCoinSaveState() {
        // Setup
        let coin = CoinFactoryMock.makeCoin()
        
        // Toggle save state on
        viewModel.toggleSaveState(for: coin)
        XCTAssertTrue(viewModel.isCoinSaved(coin))
        
        // Toggle save state off
        viewModel.toggleSaveState(for: coin)
        XCTAssertFalse(viewModel.isCoinSaved(coin))
    }
}
