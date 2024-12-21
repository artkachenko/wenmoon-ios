//
//  CoinListViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.04.23.
//

import XCTest
@testable import WenMoon

class CoinListViewModelTests: XCTestCase {
    // MARK: - Properties
    var viewModel: CoinListViewModel!
    var coinScannerService: CoinScannerServiceMock!
    var priceAlertService: PriceAlertServiceMock!
    var firebaseAuthService: FirebaseAuthServiceMock!
    var userDefaultsManager: UserDefaultsManagerMock!
    var swiftDataManager: SwiftDataManagerMock!
    var deviceToken: String!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        coinScannerService = CoinScannerServiceMock()
        priceAlertService = PriceAlertServiceMock()
        firebaseAuthService = FirebaseAuthServiceMock()
        userDefaultsManager = UserDefaultsManagerMock()
        swiftDataManager = SwiftDataManagerMock()
        viewModel = CoinListViewModel(
            coinScannerService: coinScannerService,
            priceAlertService: priceAlertService,
            firebaseAuthService: firebaseAuthService,
            userDefaultsManager: userDefaultsManager,
            swiftDataManager: swiftDataManager
        )
        deviceToken = "expectedDeviceToken"
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
    // Fetch Coins
    func testFetchCoins_isFirstLaunch() async throws {
        // Setup
        userDefaultsManager.getObjectReturnValue = ["isFirstLaunch": true]
        let coins = CoinFactoryMock.makeCoins()
        coinScannerService.getCoinsByIDsResult = .success(coins)
        
        // Action
        await viewModel.fetchCoins()
        
        // Assertions
        assertCoinsEqual(viewModel.coins, coins)
        assertInsertAndSaveMethodsCalled()
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchCoins_isFirstLaunch_networkError() async throws {
        // Setup
        userDefaultsManager.getObjectReturnValue = ["isFirstLaunch": true]
        let error = ErrorFactoryMock.makeNoNetworkConnectionError()
        coinScannerService.getCoinsByIDsResult = .failure(error)
        
        // Action
        await viewModel.fetchCoins()
        
        // Assertions
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testFetchCoins_isNotFirstLaunch_savedOrder() async throws {
        // Setup
        let coins = CoinFactoryMock.makeCoins().shuffled()
        let savedOrder = coins.map(\.id)
        userDefaultsManager.getObjectReturnValue = [
            "isFirstLaunch": false,
            "coinsOrder": savedOrder
        ]
        for coin in coins {
            let newCoin = CoinFactoryMock.makeCoinData(from: coin)
            swiftDataManager.fetchResult.append(newCoin)
        }
        let marketData = MarketDataFactoryMock.makeMarketData(for: coins)
        coinScannerService.getMarketDataResult = .success(marketData)
        
        // Action
        await viewModel.fetchCoins()
        
        // Assertions
        XCTAssert(swiftDataManager.fetchMethodCalled)
        XCTAssertEqual(viewModel.coins.map(\.id), savedOrder)
        assertCoinsEqual(viewModel.coins, coins, marketData: marketData)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testFetchCoins_isNotFirstLaunch_success() async throws {
        // Setup
        userDefaultsManager.getObjectReturnValue = ["isFirstLaunch": false]
        let coins = CoinFactoryMock.makeCoins()
        for coin in coins {
            let newCoin = CoinFactoryMock.makeCoinData(from: coin)
            swiftDataManager.fetchResult.append(newCoin)
        }
        let marketData = MarketDataFactoryMock.makeMarketData(for: coins)
        coinScannerService.getMarketDataResult = .success(marketData)
        
        // Action
        await viewModel.fetchCoins()
        
        // Assertions
        XCTAssert(swiftDataManager.fetchMethodCalled)
        assertCoinsEqual(viewModel.coins, coins, marketData: marketData)
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
        XCTAssert(viewModel.coins.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // Save Coin/Order
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
    
    func testUnarchiveCoin() async throws {
        // Setup
        let coin = CoinFactoryMock.makeCoin()
        let archivedCoin = CoinFactoryMock.makeCoinData(from: coin, isArchived: true)
        swiftDataManager.fetchResult = [archivedCoin]
        
        // Action
        await viewModel.saveCoin(coin)
        
        // Assertions
        XCTAssertEqual(viewModel.coins.count, 1)
        assertCoinsEqual(viewModel.coins, [coin])
        XCTAssertFalse(archivedCoin.isArchived)
        XCTAssert(swiftDataManager.saveMethodCalled)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testSaveCoinsOrder_success() throws {
        // Setup
        let coins = CoinFactoryMock.makeCoinsData()
        viewModel.coins = coins
        
        // Action
        viewModel.saveCoinsOrder()
        
        // Assertions
        XCTAssert(userDefaultsManager.setObjectCalled)
        XCTAssertEqual(userDefaultsManager.setObjectValue["coinsOrder"] as! [String], coins.map(\.id))
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // Delete Coin
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
    
    func testArchiveCoin() async throws {
        // Setup
        let coin = CoinFactoryMock.makeCoin()
        await viewModel.saveCoin(coin)
        let unarchivedCoin = CoinFactoryMock.makeCoinData(from: coin)
        let portfolio = PortfolioFactoryMock.makePortfolio(
            transactions: [
                PortfolioFactoryMock.makeTransaction(coin: unarchivedCoin)
            ]
        )
        swiftDataManager.fetchResult = [portfolio]
        
        // Action
        await viewModel.deleteCoin(coin.id)
        
        // Assertions
        XCTAssertFalse(unarchivedCoin.isArchived)
        XCTAssert(swiftDataManager.saveMethodCalled)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    // Market Data
    func testFetchMarketData_success() async throws {
        // Setup
        let marketData = MarketDataFactoryMock.makeMarketData()
        coinScannerService.getMarketDataResult = .success(marketData)
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
        coinScannerService.getMarketDataResult = .failure(error)
        let coin = CoinFactoryMock.makeCoinData()
        viewModel.coins.append(coin)
        
        // Action
        await viewModel.fetchMarketData()
        
        // Assertions
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
    }
    
    func testClearCache_resetsMarketData() async throws {
        // Setup
        let marketData = MarketDataFactoryMock.makeMarketData()
        viewModel.marketData = marketData
        
        // Action
        viewModel.clearCacheIfNeeded()
        
        // Assertions
        XCTAssert(viewModel.marketData.isEmpty)
    }
    
    // Price Alerts
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
        let priceAlert = priceAlerts.first(where: { $0.id == coin.id })!
        assertCoinHasAlert(viewModel.coins.first!, priceAlert)
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
    
    func testToggleOffPriceAlert() async throws {
        // Setup
        let coin = CoinFactoryMock.makeCoinData()
        let priceAlert = PriceAlertFactoryMock.makePriceAlert()
        coin.priceAlerts.append(priceAlert)
        viewModel.coins.append(coin)
        
        // Assertions after setting the price alert
        assertCoinHasAlert(coin, priceAlert)
        
        // Action
        viewModel.toggleOffPriceAlert(for: coin.id)
        
        // Assertions after deleting the price alert
        assertCoinHasNoAlert(coin)
    }
    
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
        XCTAssert(viewModel.globalMarketItems.isEmpty)
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
        XCTAssert(viewModel.globalMarketItems.isEmpty)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, error.errorDescription)
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
