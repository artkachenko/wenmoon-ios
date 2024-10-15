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
    var priceAlertService: PriceAlertService!
    var swiftDataManager: SwiftDataManagerMock!

    // MARK: - Setup
    override func setUp() {
        super.setUp()
        coinScannerService = CoinScannerServiceMock()
        priceAlertService = PriceAlertServiceImpl()
        swiftDataManager = SwiftDataManagerMock()
        viewModel = CoinListViewModel(
            coinScannerService: coinScannerService,
            priceAlertService: priceAlertService,
            swiftDataManager: swiftDataManager
        )
    }

    override func tearDown() {
        viewModel = nil
        coinScannerService = nil
        priceAlertService = nil
        swiftDataManager = nil
        super.tearDown()
    }

    // MARK: - Tests
    func testFetchCoinsSuccess() async throws {
        let marketData = makeMarketData()
        coinScannerService.getMarketDataForCoinsResult = .success(marketData)
        
        for coin in makeCoins() {
            let newCoin = makeCoinData(from: coin)
            swiftDataManager.fetchResult.append(newCoin)
        }
        await viewModel.fetchCoins()
        
        XCTAssert(swiftDataManager.fetchMethodCalled)

        let coins = viewModel.coins
        XCTAssertFalse(coins.isEmpty)
        XCTAssertEqual(coins.count, coins.count)

        let mockCoins = makeCoins()
        assertCoin(coins.first!, mockCoins.first!, marketData[mockCoins.first!.id])
        assertCoin(coins.last!, mockCoins.last!, marketData[mockCoins.last!.id])
    }
    
    func testFetchCoinsEmptyResult() async throws {
        await viewModel.fetchCoins()

        XCTAssertTrue(viewModel.coins.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testConstructCoin() async throws {
        let coin = makeBitcoin()
        await viewModel.createCoin(coin)

        let coins = viewModel.coins
        XCTAssertFalse(coins.isEmpty)
        XCTAssertEqual(coins.count, 1)
        XCTAssertNotNil(coins.first!.imageData)

        assertCoin(coins.first!, coin)
        
        XCTAssert(swiftDataManager.saveMethodCalled)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSetPriceAlert() async throws {
        let coin = makeCoinData()
        viewModel.coins.append(coin)

        await viewModel.setPriceAlert(for: coin, targetPrice: 30000)

        XCTAssertTrue(coin.isActive)
        XCTAssertEqual(coin.targetPrice, 30000)

        await viewModel.setPriceAlert(for: coin, targetPrice: nil)

        XCTAssertFalse(coin.isActive)
        XCTAssertNil(coin.targetPrice)
    }

    func testDeleteCoin() async throws {
        let coin = makeCoinData()
        try swiftDataManager.save()

        XCTAssert(swiftDataManager.saveMethodCalled)

        await viewModel.deleteCoin(coin)

        XCTAssert(swiftDataManager.deleteMethodCalled)
        XCTAssertEqual(swiftDataManager.deletedModel as? CoinData, coin)

        XCTAssertNil(viewModel.errorMessage)
    }
}
