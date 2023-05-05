//
//  PriceAlertListViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.04.23.
//

import XCTest
import CoreData
import Combine
@testable import WenMoon

class PriceAlertListViewModelTests: XCTestCase {

    // MARK: - Properties

    var viewModel: PriceAlertListViewModel!
    var service: CoinScannerServiceMock!
    var persistence: PersistenceManagerMock!
    var cancellables: Set<AnyCancellable>!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        service = CoinScannerServiceMock()
        persistence = PersistenceManagerMock()
        viewModel = PriceAlertListViewModel(service: service, persistence: persistence)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        viewModel = nil
        service = nil
        persistence = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testFetchPriceAlertsSuccess() {
        let coins: [Coin] = [.btc, .eth]
        let marketData = CoinMarketData.mock
        service.getMarketDataForCoinIDsResult = .success(marketData)

        for coin in coins {
            let newPriceAlert = PriceAlert(context: persistence.context)
            newPriceAlert.id = coin.id
            newPriceAlert.name = coin.name
            newPriceAlert.image = coin.image
            newPriceAlert.rank = coin.marketCapRank!
            newPriceAlert.currentPrice = marketData[coin.id]!.currentPrice!
            newPriceAlert.priceChange = marketData[coin.id]!.priceChange!

            persistence.fetchRequestResult.append(newPriceAlert)
        }

        let expectation = XCTestExpectation(description: "Fetch price alerts")
        viewModel.$priceAlerts
            .dropFirst()
            .sink { priceAlerts in
                XCTAssertFalse(priceAlerts.isEmpty)
                XCTAssertEqual(priceAlerts.count, coins.count)

                XCTAssertEqual(priceAlerts.first?.id, coins.first?.id)
                XCTAssertEqual(priceAlerts.first?.name, coins.first?.name)
                XCTAssertEqual(priceAlerts.first?.image, coins.first?.image)
                XCTAssertEqual(priceAlerts.first?.rank, coins.first?.marketCapRank)
                XCTAssertEqual(priceAlerts.first?.currentPrice, marketData[coins.first!.id]?.currentPrice)
                XCTAssertEqual(priceAlerts.first?.priceChange, marketData[coins.first!.id]?.priceChange)
                XCTAssertNotNil(priceAlerts.first?.imageData)

                XCTAssertEqual(priceAlerts.last?.id, coins.last?.id)
                XCTAssertEqual(priceAlerts.last?.name, coins.last?.name)
                XCTAssertEqual(priceAlerts.last?.image, coins.last?.image)
                XCTAssertEqual(priceAlerts.last?.rank, coins.last?.marketCapRank)
                XCTAssertEqual(priceAlerts.last?.currentPrice, marketData[coins.last!.id]?.currentPrice)
                XCTAssertEqual(priceAlerts.last?.priceChange, marketData[coins.last!.id]?.priceChange)
                XCTAssertNotNil(priceAlerts.last?.imageData)

                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchPriceAlerts()

        wait(for: [expectation], timeout: 1)

        XCTAssert(persistence.fetchMethodCalled)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFetchPriceAlertsEmptyResult() {
        let coins: [Coin] = []
        let marketData = CoinMarketData.mock
        service.getMarketDataForCoinIDsResult = .success(marketData)

        for coin in coins {
            let newPriceAlert = PriceAlert(context: persistence.context)
            newPriceAlert.id = coin.id
            newPriceAlert.name = coin.name
            newPriceAlert.image = coin.image
            newPriceAlert.rank = coin.marketCapRank!
            newPriceAlert.currentPrice = marketData[coin.id]!.currentPrice!
            newPriceAlert.priceChange = marketData[coin.id]!.priceChange!

            persistence.fetchRequestResult.append(newPriceAlert)
        }

        let expectation = XCTestExpectation(description: "Fetch empty price alerts")
        viewModel.$priceAlerts
            .dropFirst()
            .sink { priceAlerts in
                XCTAssert(priceAlerts.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchPriceAlerts()

        wait(for: [expectation], timeout: 1)

        XCTAssertNil(viewModel.errorMessage)
    }

    func testCreateNewPriceAlert() {
        let coin: Coin = .btc

        let expectation = XCTestExpectation(description: "Create new price alert")
        viewModel.$priceAlerts
            .dropFirst()
            .sink { priceAlerts in
                XCTAssertFalse(priceAlerts.isEmpty)
                XCTAssertEqual(priceAlerts.count, 1)

                XCTAssertEqual(priceAlerts.first?.id, coin.id)
                XCTAssertEqual(priceAlerts.first?.name, coin.name)
                XCTAssertEqual(priceAlerts.first?.image, coin.image)
                XCTAssertNotNil(priceAlerts.first?.imageData)
                XCTAssertEqual(priceAlerts.first?.rank, coin.marketCapRank)
                XCTAssertEqual(priceAlerts.first?.currentPrice, coin.currentPrice)
                XCTAssertEqual(priceAlerts.first?.priceChange, coin.priceChangePercentage24H)

                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.createNewPriceAlert(from: coin)

        wait(for: [expectation], timeout: 1)

        XCTAssert(persistence.saveMethodCalled)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSetPriceAlert() {
        let coin: Coin = .btc
        
        let priceAlert = PriceAlert(context: persistence.context)
        priceAlert.id = coin.id
        priceAlert.name = coin.name
        priceAlert.image = coin.image
        priceAlert.rank = coin.marketCapRank!
        priceAlert.currentPrice = coin.currentPrice!
        priceAlert.priceChange = coin.priceChangePercentage24H!

        viewModel.priceAlerts.append(priceAlert)

        viewModel.setPriceAlert(priceAlert, targetPrice: 30000)

        XCTAssertTrue(priceAlert.isActive)
        XCTAssertEqual(priceAlert.targetPrice, 30000)

        viewModel.setPriceAlert(priceAlert, targetPrice: nil)

        XCTAssertFalse(priceAlert.isActive)
        XCTAssertNil(priceAlert.targetPrice)
    }

    func testDeletePriceAlert() {
        let coin = Coin.btc
        let marketData = CoinMarketData.mock

        let priceAlert = PriceAlert(context: persistence.context)
        priceAlert.id = coin.id
        priceAlert.name = coin.name
        priceAlert.image = coin.image
        priceAlert.currentPrice = marketData[coin.id]!.currentPrice!
        priceAlert.priceChange = marketData[coin.id]!.priceChange!

        persistence.save()

        XCTAssert(persistence.saveMethodCalled)

        viewModel.delete(priceAlert)

        XCTAssert(persistence.deleteMethodCalled)
        XCTAssertEqual(persistence.deletedObject, priceAlert)

        XCTAssertNil(viewModel.errorMessage)
    }
}
