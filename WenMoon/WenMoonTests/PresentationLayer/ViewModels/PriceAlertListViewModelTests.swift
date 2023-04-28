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

    func testFetchMarketDataForCoinsSuccess() {
        let coins: [Coin] = [.btc, .eth]
        let response = CoinMarketData.mock
        service.getMarketDataForCoinIDsResult = .success(response)

        let expectation = XCTestExpectation(description: "Fetch market data for coins")
        viewModel.$marketData
            .dropFirst()
            .sink { marketData in
                XCTAssertFalse(marketData.isEmpty)
                XCTAssertEqual(marketData.count, coins.count)

                XCTAssertEqual(marketData[coins.first!.id]?.usd, response[coins.first!.id]?.usd)
                XCTAssertEqual(marketData[coins.first!.id]?.usd24HChange, response[coins.first!.id]?.usd24HChange)

                XCTAssertEqual(marketData[coins.last!.id]?.usd, response[coins.last!.id]?.usd)
                XCTAssertEqual(marketData[coins.last!.id]?.usd24HChange, response[coins.last!.id]?.usd24HChange)

                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchMarketData(for: coins)

        wait(for: [expectation], timeout: 1)

        XCTAssertNil(viewModel.errorMessage)
    }

    func testFetchMarketDataForCoinsFailure() {
        let coins: [Coin] = [.btc, .eth]
        let apiError: APIError = .apiError(error: .init(.badServerResponse), description: "Mocked server error")
        service.getMarketDataForCoinIDsResult = .failure(apiError)

        let expectation = XCTestExpectation(description: "Get a failure with API error")
        viewModel.$errorMessage
            .dropFirst()
            .sink { errorMessage in
                XCTAssertNotNil(errorMessage)
                XCTAssertEqual(errorMessage, apiError.errorDescription)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchMarketData(for: coins)

        wait(for: [expectation], timeout: 1)
    }

    func testFetchPriceAlerts() {
        let coins: [Coin] = [.btc, .eth]
        let marketData = CoinMarketData.mock
        service.getMarketDataForCoinIDsResult = .success(marketData)

        for coin in coins {
            let newPriceAlert = PriceAlert(context: persistence.context)
            newPriceAlert.id = coin.id
            newPriceAlert.name = coin.name
            newPriceAlert.image = coin.image
            newPriceAlert.rank = coin.marketCapRank
            newPriceAlert.currentPrice = marketData[coin.id]!.usd
            newPriceAlert.priceChange = marketData[coin.id]!.usd24HChange

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
                XCTAssertEqual(priceAlerts.first?.currentPrice, marketData[coins.first!.id]?.usd)
                XCTAssertEqual(priceAlerts.first?.priceChange, marketData[coins.first!.id]?.usd24HChange)
                XCTAssertNotNil(priceAlerts.first?.imageData)

                XCTAssertEqual(priceAlerts.last?.id, coins.last?.id)
                XCTAssertEqual(priceAlerts.last?.name, coins.last?.name)
                XCTAssertEqual(priceAlerts.last?.image, coins.last?.image)
                XCTAssertEqual(priceAlerts.last?.rank, coins.last?.marketCapRank)
                XCTAssertEqual(priceAlerts.last?.currentPrice, marketData[coins.last!.id]?.usd)
                XCTAssertEqual(priceAlerts.last?.priceChange, marketData[coins.last!.id]?.usd24HChange)
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
            newPriceAlert.rank = coin.marketCapRank
            newPriceAlert.currentPrice = marketData[coin.id]!.usd
            newPriceAlert.priceChange = marketData[coin.id]!.usd24HChange

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
    }

    func testSavePriceAlerts() {
        let coins: [Coin] = [.btc, .eth]
        let marketData = CoinMarketData.mock

        let expectation = XCTestExpectation(description: "Save price alerts")
        viewModel.$priceAlerts
            .dropFirst(3)
            .sink { priceAlerts in
                XCTAssertFalse(priceAlerts.isEmpty)
                XCTAssertEqual(priceAlerts.count, coins.count)

                XCTAssertEqual(priceAlerts.first?.id, coins.first?.id)
                XCTAssertEqual(priceAlerts.first?.name, coins.first?.name)
                XCTAssertEqual(priceAlerts.first?.image, coins.first?.image)
                XCTAssertEqual(priceAlerts.first?.rank, coins.first?.marketCapRank)
                XCTAssertEqual(priceAlerts.first?.currentPrice, marketData[coins.first!.id]?.usd)
                XCTAssertEqual(priceAlerts.first?.priceChange, marketData[coins.first!.id]?.usd24HChange)
                XCTAssertNotNil(priceAlerts.first?.imageData)

                XCTAssertEqual(priceAlerts.last?.id, coins.last?.id)
                XCTAssertEqual(priceAlerts.last?.name, coins.last?.name)
                XCTAssertEqual(priceAlerts.last?.image, coins.last?.image)
                XCTAssertEqual(priceAlerts.last?.rank, coins.last?.marketCapRank)
                XCTAssertEqual(priceAlerts.last?.currentPrice, marketData[coins.last!.id]?.usd)
                XCTAssertEqual(priceAlerts.last?.priceChange, marketData[coins.last!.id]?.usd24HChange)
                XCTAssertNotNil(priceAlerts.last?.imageData)

                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.savePriceAlerts(coins, marketData)

        wait(for: [expectation], timeout: 1)

        XCTAssert(persistence.saveMethodCalled)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testDeletePriceAlert() {
        let coin = Coin.btc
        let marketData = CoinMarketData.mock

        let priceAlert = PriceAlert(context: persistence.context)
        priceAlert.id = coin.id
        priceAlert.name = coin.name
        priceAlert.image = coin.image
        priceAlert.currentPrice = marketData[coin.id]!.usd
        priceAlert.priceChange = marketData[coin.id]!.usd24HChange

        persistence.save()

        XCTAssert(persistence.saveMethodCalled)

        viewModel.delete(priceAlert)

        XCTAssert(persistence.deleteMethodCalled)
        XCTAssertEqual(persistence.deletedObject, priceAlert)

        XCTAssertNil(viewModel.errorMessage)
    }
}
