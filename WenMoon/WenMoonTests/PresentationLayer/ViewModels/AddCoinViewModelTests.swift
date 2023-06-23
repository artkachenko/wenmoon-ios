//
//  AddCoinViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.04.23.
//

import XCTest
import Combine
@testable import WenMoon

class AddCoinViewModelTests: XCTestCase {

    // MARK: - Properties

    var viewModel: AddCoinViewModel!
    var service: CoinScannerServiceMock!
    var cancellables: Set<AnyCancellable>!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        service = CoinScannerServiceMock()
        viewModel = AddCoinViewModel(coinScannerService: service)
        cancellables = Set<AnyCancellable>()
    }

    override func tearDown() {
        viewModel = nil
        service = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testFetchCoinsSuccess() {
        let response: [Coin] = [.btc, .eth]
        service.getCoinsAtPageResult = .success(response)

        let expectation = XCTestExpectation(description: "Fetch an array of coins on page 1")
        viewModel.$coins
            .dropFirst()
            .sink { coins in
                XCTAssertFalse(coins.isEmpty)
                XCTAssertEqual(coins.count, response.count)

                XCTAssertEqual(coins.first?.id, response.first?.id)
                XCTAssertEqual(coins.first?.name, response.first?.name)
                XCTAssertEqual(coins.first?.image, response.first?.image)

                XCTAssertEqual(coins.last?.id, response.last?.id)
                XCTAssertEqual(coins.last?.name, response.last?.name)
                XCTAssertEqual(coins.last?.image, response.last?.image)

                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchCoins()

        wait(for: [expectation], timeout: 1)

        XCTAssertNil(viewModel.errorMessage)
    }

    func testFetchCoinsFailure() {
        let apiError: APIError = .apiError(error: .init(.badServerResponse), description: "Mocked server error")
        service.getCoinsAtPageResult = .failure(apiError)

        let expectation = XCTestExpectation(description: "Get a failure with API error")
        viewModel.$errorMessage
            .dropFirst()
            .sink { errorMessage in
                XCTAssertNotNil(errorMessage)
                XCTAssertEqual(errorMessage, apiError.errorDescription)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.fetchCoins()

        wait(for: [expectation], timeout: 1)
    }

    func testSearchCoinsByQuerySuccess() {
        let coinSearchResult = CoinSearchResult.mock
        let marketDataResponse = MarketData.mock
        service.searchCoinsByQueryResult = .success(coinSearchResult)
        service.getMarketDataForCoinsResult = .success(marketDataResponse)

        let expectation = XCTestExpectation(description: "Search for a specific coins by query")
        let combinedPublisher = Publishers.CombineLatest(viewModel.$coins, viewModel.$marketData)
        combinedPublisher
            .dropFirst(2)
            .sink { coins, marketData in
                XCTAssertFalse(coins.isEmpty)
                XCTAssertEqual(coins.count, coinSearchResult.coins.count)

                XCTAssertEqual(coins.first?.id, coinSearchResult.coins.first?.id)
                XCTAssertEqual(coins.first?.name, coinSearchResult.coins.first?.name)
                XCTAssertEqual(coins.first?.image, coinSearchResult.coins.first?.image)
                XCTAssertEqual(coins.first?.marketCapRank, coinSearchResult.coins.first?.marketCapRank)
                XCTAssertEqual(marketData[coins.first!.id]?.currentPrice, marketDataResponse[coinSearchResult.coins.first!.id]?.currentPrice)
                XCTAssertEqual(marketData[coins.first!.id]?.priceChange, marketDataResponse[coinSearchResult.coins.first!.id]?.priceChange)
                
                XCTAssertEqual(coins.last?.id, coinSearchResult.coins.last?.id)
                XCTAssertEqual(coins.last?.name, coinSearchResult.coins.last?.name)
                XCTAssertEqual(coins.last?.image, coinSearchResult.coins.last?.image)
                XCTAssertEqual(coins.last?.marketCapRank, coinSearchResult.coins.last?.marketCapRank)
                XCTAssertEqual(marketData[coins.last!.id]?.currentPrice, marketDataResponse[coinSearchResult.coins.last!.id]?.currentPrice)
                XCTAssertEqual(marketData[coins.last!.id]?.priceChange, marketDataResponse[coinSearchResult.coins.last!.id]?.priceChange)

                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.searchCoins(by: "bit")

        wait(for: [expectation], timeout: 1)

        XCTAssertNil(viewModel.errorMessage)
    }

    func testSearchCoinsByQueryEmptyResult() {
        let response = CoinSearchResult.mock
        service.searchCoinsByQueryResult = .success(response)

        let expectation = XCTestExpectation(description: "Search for a specific coins by invalid query")
        viewModel.$coins
            .sink { coins in
                XCTAssert(coins.isEmpty)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        viewModel.searchCoins(by: "sdfghjkl")

        wait(for: [expectation], timeout: 1)

        XCTAssertNil(viewModel.errorMessage)
    }
}
