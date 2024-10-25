//
//  CoinListViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.04.23.
//

import XCTest
@testable import WenMoon

@MainActor
class CoinListViewModelTests: XCTestCase {
    // MARK: - Properties
    var viewModel: CoinListViewModel!
    var coinScannerService: CoinScannerServiceMock!
    var priceAlertService: PriceAlertServiceMock!
    var userDefaultsManager: UserDefaultsManagerMock!
    var swiftDataManager: SwiftDataManagerMock!
    var deviceToken: String!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        coinScannerService = CoinScannerServiceMock()
        priceAlertService = PriceAlertServiceMock()
        userDefaultsManager = UserDefaultsManagerMock()
        swiftDataManager = SwiftDataManagerMock()
        viewModel = CoinListViewModel(
            coinScannerService: coinScannerService,
            priceAlertService: priceAlertService,
            userDefaultsManager: userDefaultsManager,
            swiftDataManager: swiftDataManager
        )
        deviceToken = "someDeviceToken"
    }
    
    override func tearDown() {
        viewModel = nil
        coinScannerService = nil
        priceAlertService = nil
        swiftDataManager = nil
        deviceToken = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    // Fetch Coins Tests
    func testFetchCoins_isFirstLaunch() async throws {
        // Setup
        userDefaultsManager.getObjectReturnValue = ["isFirstLaunch": true]
        
        // Action
        await viewModel.fetchCoins()
        
        // Assertions
        assertCoinsEqual(viewModel.coins, CoinData.predefinedCoins)
        assertInsertAndSaveMethodsCalled()
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchCoins_isNotFirstLaunch_success() async throws {
        // Setup
        userDefaultsManager.getObjectReturnValue = ["isFirstLaunch": false]
        let mockCoins = CoinFactoryMock.makeCoins()
        for coin in mockCoins {
            let newCoin = CoinFactoryMock.makeCoinData(from: coin)
            swiftDataManager.fetchResult.append(newCoin)
        }
        
        // Action
        await viewModel.fetchCoins()
        
        // Assertions
        XCTAssert(swiftDataManager.fetchMethodCalled)
        assertCoinsEqual(viewModel.coins, mockCoins)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchCoins_isNotFirstLaunch_fetchError() async throws {
        // Setup
        userDefaultsManager.getObjectReturnValue = ["isFirstLaunch": false]
        let error: SwiftDataError = .failedToFetchModels
        swiftDataManager.swiftDataError = error
        
        // Action
        await viewModel.fetchCoins()
        
        // Assertions
        XCTAssert(swiftDataManager.fetchMethodCalled)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testFetchCoins_emptyResult() async throws {
        // Setup
        userDefaultsManager.getObjectReturnValue = ["isFirstLaunch": false]
        
        // Action
        await viewModel.fetchCoins()
        
        // Assertions
        XCTAssertTrue(viewModel.coins.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // Save Coin Tests
    func testSaveCoin_success() async throws {
        // Setup
        let coin = CoinFactoryMock.makeCoin()
        
        // Action
        await viewModel.saveCoin(coin)
        
        // Assertions
        XCTAssertEqual(viewModel.coins.count, 1)
        assertCoinsEqual(viewModel.coins, [coin])
        assertInsertAndSaveMethodsCalled()
        XCTAssertNil(viewModel.errorMessage)
        
        // Save the same coin again
        await viewModel.saveCoin(coin)
        XCTAssertEqual(viewModel.coins.count, 1)
    }
    
    func testSaveCoin_saveError() async throws {
        // Setup
        let error: SwiftDataError = .failedToSaveModel
        swiftDataManager.swiftDataError = error
        
        // Action
        let coin = CoinFactoryMock.makeCoin()
        await viewModel.saveCoin(coin)
        
        // Assertions
        assertInsertAndSaveMethodsCalled()
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    // Delete Coin Tests
    func testDeleteCoin_success() async throws {
        // Setup
        let coin = CoinFactoryMock.makeCoin()
        await viewModel.saveCoin(coin)
        
        // Action
        await viewModel.deleteCoin(coin.id)
        
        // Assertions
        assertDeleteAndSaveMethodsCalled()
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testDeleteCoin_saveError() async throws {
        // Setup
        let coin = CoinFactoryMock.makeCoin()
        await viewModel.saveCoin(coin)
        let error: SwiftDataError = .failedToSaveModel
        swiftDataManager.swiftDataError = error
        
        // Action
        await viewModel.deleteCoin(coin.id)
        
        // Assertions
        assertDeleteAndSaveMethodsCalled()
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    // Market Data
    func testFetchMarketData_success() async throws {
        // Setup
        let marketData = MarketDataFactoryMock.makeMarketData()
        coinScannerService.getMarketDataForCoinsResult = .success(marketData)
        let coins = CoinFactoryMock.makeCoinsData()
        viewModel.coins.append(contentsOf: coins)
        
        // Action
        await viewModel.fetchMarketData()
        
        // Assertions
        assertMarketDataEqual(for: viewModel.coins, with: marketData)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchMarketData_usesCache() async throws {
        // Setup
        let marketData = MarketDataFactoryMock.makeMarketData()
        viewModel.marketData = marketData
        let coins = CoinFactoryMock.makeCoinsData()
        viewModel.coins.append(contentsOf: coins)
        
        // Action
        await viewModel.fetchMarketData()
        
        // Assertions
        assertMarketDataEqual(viewModel.marketData, marketData, for: coins.map(\.id))
    }
    
    func testFetchMarketData_apiError() async throws {
        // Setup
        let error = ErrorFactoryMock.makeAPIError()
        coinScannerService.getMarketDataForCoinsResult = .failure(error)
        let coin = CoinFactoryMock.makeCoinData()
        viewModel.coins.append(coin)
        
        // Action
        await viewModel.fetchMarketData()
        
        // Assertions
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    // Price Alerts Tests
    func testFetchPriceAlerts_success() async throws {
        // Setup
        userDefaultsManager.getObjectReturnValue = ["deviceToken": deviceToken!]
        let coin = CoinFactoryMock.makeCoinData()
        viewModel.coins.append(coin)
        let priceAlerts = PriceAlertFactoryMock.makePriceAlerts()
        priceAlertService.getPriceAlertsResult = .success(priceAlerts)
        
        // Action
        await viewModel.fetchPriceAlerts()
        
        // Assertions
        let priceAlert = priceAlerts.first(where: { $0.coinId == coin.id })!
        assertCoinHasAlert(viewModel.coins.first!, priceAlert.targetPrice)
        XCTAssertNil(viewModel.errorMessage)
        
        // Test after alerts are cleared
        priceAlertService.getPriceAlertsResult = .success([])
        await viewModel.fetchPriceAlerts()
        
        assertCoinHasNoAlert(viewModel.coins.first!)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchPriceAlerts_invalidEndpoint() async throws {
        // Setup
        userDefaultsManager.getObjectReturnValue = ["deviceToken": deviceToken!]
        let coin = CoinFactoryMock.makeCoinData()
        viewModel.coins.append(coin)
        let error = ErrorFactoryMock.makeInvalidEndpointError()
        priceAlertService.getPriceAlertsResult = .failure(error)
        
        // Action
        await viewModel.fetchPriceAlerts()
        
        // Assertions
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testSetPriceAlert_success() async throws {
        // Setup
        userDefaultsManager.getObjectReturnValue = ["deviceToken": deviceToken!]
        let coin = CoinFactoryMock.makeCoinData()
        let targetPrice: Double = 70000
        viewModel.coins.append(coin)
        let priceAlert = PriceAlertFactoryMock.makePriceAlert()
        priceAlertService.setPriceAlertResult = .success(priceAlert)
        
        // Action - Set the price alert
        await viewModel.setPriceAlert(for: coin, targetPrice: targetPrice)
        
        // Assertions after setting the price alert
        assertCoinHasAlert(viewModel.coins.first!, targetPrice)
        XCTAssertNil(viewModel.errorMessage)
        
        // Action - Delete Price Alert
        priceAlertService.deletePriceAlertResult = .success(priceAlert)
        await viewModel.setPriceAlert(for: coin, targetPrice: nil)
        
        // Assertions after deleting the price alert
        assertCoinHasNoAlert(viewModel.coins.first!)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSetPriceAlert_encodingError() async throws {
        // Setup
        userDefaultsManager.getObjectReturnValue = ["deviceToken": deviceToken!]
        let coin = CoinFactoryMock.makeCoinData()
        viewModel.coins.append(coin)
        let error = ErrorFactoryMock.makeFailedToEncodeBodyError()
        priceAlertService.setPriceAlertResult = .failure(error)
        
        // Action
        await viewModel.setPriceAlert(for: coin, targetPrice: 70000)
        
        // Assertions
        assertCoinHasNoAlert(coin)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testToggleOffPriceAlert() async throws {
        // Setup
        let coin = CoinFactoryMock.makeCoinData()
        let targetPrice: Double = 70000
        coin.targetPrice = targetPrice
        coin.isActive = true
        viewModel.coins.append(coin)
        
        // Assertions after setting the price alert
        assertCoinHasAlert(coin, targetPrice)
        
        // Action
        viewModel.toggleOffPriceAlert(for: coin.id)
        
        // Assertions after deleting the price alert
        assertCoinHasNoAlert(coin)
        XCTAssert(swiftDataManager.saveMethodCalled)
    }
    
    // MARK: - Helpers
    private func assertInsertAndSaveMethodsCalled() {
        XCTAssert(swiftDataManager.insertMethodCalled)
        XCTAssert(swiftDataManager.saveMethodCalled)
    }
    
    private func assertDeleteAndSaveMethodsCalled() {
        XCTAssert(swiftDataManager.deleteMethodCalled)
        XCTAssert(swiftDataManager.saveMethodCalled)
    }
}
