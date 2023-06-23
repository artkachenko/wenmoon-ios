//
//  CoinListViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.04.23.
//

import XCTest
import CoreData
import Combine
@testable import WenMoon

class CoinListViewModelTests: XCTestCase {

    // MARK: - Properties

    var viewModel: CoinListViewModel!
    var coinScannerService: CoinScannerServiceMock!
    var priceAlertService: PriceAlertService!
    var persistenceManager: PersistenceManagerMock!
    var cancellables: Set<AnyCancellable>!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        coinScannerService = CoinScannerServiceMock()
        priceAlertService = PriceAlertServiceImpl()
        persistenceManager = PersistenceManagerMock()
        viewModel = CoinListViewModel(coinScannerService: coinScannerService,
                                      priceAlertService: priceAlertService)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        viewModel = nil
        coinScannerService = nil
        priceAlertService = nil
        persistenceManager = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testFetchCoinsSuccess() {
        let coins: [Coin] = [.btc, .eth]
        let marketData = MarketData.mock
        coinScannerService.getMarketDataForCoinsResult = .success(marketData)

        for coin in coins {
            let newCoin = CoinEntity(context: persistenceManager.context)
            newCoin.id = coin.id
            newCoin.name = coin.name
            newCoin.image = coin.image
            newCoin.rank = coin.marketCapRank!
            newCoin.currentPrice = marketData[coin.id]!.currentPrice!
            newCoin.priceChange = marketData[coin.id]!.priceChange!

            persistenceManager.fetchRequestResult.append(newCoin)
        }

        let expectation = XCTestExpectation(description: "Fetch coins")
        viewModel.$coins
            .dropFirst()
            .sink { receivedCoins in
                XCTAssertFalse(receivedCoins.isEmpty)
                XCTAssertEqual(receivedCoins.count, coins.count)

                XCTAssertEqual(receivedCoins.first?.id, coins.first?.id)
                XCTAssertEqual(receivedCoins.first?.name, coins.first?.name)
                XCTAssertEqual(receivedCoins.first?.image, coins.first?.image)
                XCTAssertEqual(receivedCoins.first?.rank, coins.first?.marketCapRank)
                XCTAssertEqual(receivedCoins.first?.currentPrice, marketData[coins.first!.id]?.currentPrice)
                XCTAssertEqual(receivedCoins.first?.priceChange, marketData[coins.first!.id]?.priceChange)
                XCTAssertNotNil(receivedCoins.first?.imageData)

                XCTAssertEqual(receivedCoins.last?.id, coins.last?.id)
                XCTAssertEqual(receivedCoins.last?.name, coins.last?.name)
                XCTAssertEqual(receivedCoins.last?.image, coins.last?.image)
                XCTAssertEqual(receivedCoins.last?.rank, coins.last?.marketCapRank)
                XCTAssertEqual(receivedCoins.last?.currentPrice, marketData[coins.last!.id]?.currentPrice)
                XCTAssertEqual(receivedCoins.last?.priceChange, marketData[coins.last!.id]?.priceChange)
                XCTAssertNotNil(receivedCoins.last?.imageData)

                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchCoins()

        wait(for: [expectation], timeout: 1)

        XCTAssert(persistenceManager.fetchMethodCalled)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFetchCoinsEmptyResult() {
        let coins: [Coin] = []
        let marketData = MarketData.mock
        coinScannerService.getMarketDataForCoinsResult = .success(marketData)

        for coin in coins {
            let newCoin = CoinEntity(context: persistenceManager.context)
            newCoin.id = coin.id
            newCoin.name = coin.name
            newCoin.image = coin.image
            newCoin.rank = coin.marketCapRank!
            newCoin.currentPrice = marketData[coin.id]!.currentPrice!
            newCoin.priceChange = marketData[coin.id]!.priceChange!

            persistenceManager.fetchRequestResult.append(newCoin)
        }

        let expectation = XCTestExpectation(description: "Fetch empty coins array")
        viewModel.$coins
            .dropFirst()
            .sink { priceAlerts in
                XCTAssert(priceAlerts.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchCoins()

        wait(for: [expectation], timeout: 1)

        XCTAssertNil(viewModel.errorMessage)
    }

    func testConstructCoin() {
        let coin: Coin = .btc

        let expectation = XCTestExpectation(description: "Create new price alert")
        viewModel.$coins
            .dropFirst()
            .sink { coins in
                XCTAssertFalse(coins.isEmpty)
                XCTAssertEqual(coins.count, 1)

                XCTAssertEqual(coins.first?.id, coin.id)
                XCTAssertEqual(coins.first?.name, coin.name)
                XCTAssertEqual(coins.first?.image, coin.image)
                XCTAssertNotNil(coins.first?.imageData)
                XCTAssertEqual(coins.first?.rank, coin.marketCapRank)
                XCTAssertEqual(coins.first?.currentPrice, coin.currentPrice)
                XCTAssertEqual(coins.first?.priceChange, coin.priceChangePercentage24H)

                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.createCoinEntity(coin)

        wait(for: [expectation], timeout: 1)

        XCTAssert(persistenceManager.saveMethodCalled)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSetPriceAlert() {
        let coin: Coin = .btc
        
        let newCoin = CoinEntity(context: persistenceManager.context)
        newCoin.id = coin.id
        newCoin.name = coin.name
        newCoin.image = coin.image
        newCoin.rank = coin.marketCapRank!
        newCoin.currentPrice = coin.currentPrice!
        newCoin.priceChange = coin.priceChangePercentage24H!

        viewModel.coins.append(newCoin)

        viewModel.setPriceAlert(for: newCoin, targetPrice: 30000)

        XCTAssertTrue(newCoin.isActive)
        XCTAssertEqual(newCoin.targetPrice, 30000)

        viewModel.setPriceAlert(for: newCoin, targetPrice: nil)

        XCTAssertFalse(newCoin.isActive)
        XCTAssertNil(newCoin.targetPrice)
    }

    func testDeleteCoin() {
        let coin = Coin.btc
        let marketData = MarketData.mock

        let newCoin = CoinEntity(context: persistenceManager.context)
        newCoin.id = coin.id
        newCoin.name = coin.name
        newCoin.image = coin.image
        newCoin.currentPrice = marketData[coin.id]!.currentPrice!
        newCoin.priceChange = marketData[coin.id]!.priceChange!

        persistenceManager.save()

        XCTAssert(persistenceManager.saveMethodCalled)

        viewModel.deleteCoin(newCoin)

        XCTAssert(persistenceManager.deleteMethodCalled)
        XCTAssertEqual(persistenceManager.deletedObject, newCoin)

        XCTAssertNil(viewModel.errorMessage)
    }
}
