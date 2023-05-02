//
//  CoinScannerServiceTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.04.23.
//

import XCTest
import Combine
@testable import WenMoon

class CoinScannerServiceTests: XCTestCase {

    // MARK: - Properties

    var service: CoinScannerService!
    var httpClient: HTTPClientMock!
    var cancellables: Set<AnyCancellable>!

    // MARK: - Setup

    override func setUp() {
        super.setUp()
        httpClient = HTTPClientMock()
        service = CoinScannerServiceImpl(httpClient: httpClient)
        cancellables = []
    }

    override func tearDown() {
        service = nil
        httpClient = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Tests

    func testGetCoinsSuccess() {
        let response: [Coin] = [.btc, .eth]
        httpClient.getResponse = .success(try! JSONEncoder().encode(response))

        let expectation = XCTestExpectation(description: "Get an array of coins on page 1")
        service.getCoins(at: 1)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    XCTFail("Expected success but got failure: \(error.errorDescription ?? error.localizedDescription)")
                case .finished:
                    expectation.fulfill()
                }
            }, receiveValue: { value in
                XCTAssertFalse(value.isEmpty)
                XCTAssertEqual(value.count, response.count)

                XCTAssertEqual(value.first?.id, response.first?.id)
                XCTAssertEqual(value.first?.name, response.first?.name)
                XCTAssertEqual(value.first?.image, response.first?.image)

                XCTAssertEqual(value.last?.id, response.last?.id)
                XCTAssertEqual(value.last?.name, response.last?.name)
                XCTAssertEqual(value.last?.image, response.last?.image)
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testGetCoinsFailure() {
        let apiError: APIError = .apiError(error: .init(.badServerResponse),
                                           description: "Mocked API error description")
        httpClient.getResponse = .failure(apiError)

        let expectation = XCTestExpectation(description: "Get a failure with API error")
        service.getCoins(at: 1)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    XCTAssertNotNil(error)
                    XCTAssertEqual(error, apiError)
                    expectation.fulfill()
                case .finished:
                    XCTFail("Expected failure but got success")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testSearchCoinsByQuerySuccess() {
        let response = CoinSearchResult.mock
        httpClient.getResponse = .success(try! JSONEncoder().encode(response))

        let expectation = XCTestExpectation(description: "Search for a specific coins by query")
        service.searchCoins(by: "bit")
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    XCTFail("Failed to search coins: \(error.errorDescription ?? error.localizedDescription)")
                case .finished:
                    expectation.fulfill()
                }
            }, receiveValue: { value in
                XCTAssertFalse(value.coins.isEmpty)
                XCTAssertEqual(value.coins.count, response.coins.count)

                XCTAssertEqual(value.coins.first?.id, response.coins.first?.id)
                XCTAssertEqual(value.coins.first?.name, response.coins.first?.name)
                XCTAssertEqual(value.coins.first?.image, response.coins.first?.image)

                XCTAssertEqual(value.coins.last?.id, response.coins.last?.id)
                XCTAssertEqual(value.coins.last?.name, response.coins.last?.name)
                XCTAssertEqual(value.coins.last?.image, response.coins.last?.image)
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testSearchCoinsByQueryEmptyResult() {
        let response = CoinSearchResult.emptyMock
        httpClient.getResponse = .success(try! JSONEncoder().encode(response))

        let expectation = XCTestExpectation(description: "Search for a specific coins by invalid query")
        service.searchCoins(by: "sdfghjkl")
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    XCTFail("Failed to search coins: \(error.errorDescription ?? error.localizedDescription)")
                case .finished:
                    expectation.fulfill()
                }
            }, receiveValue: { value in
                XCTAssert(value.coins.isEmpty)
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }

    func testGetMarketDataForCoinIDs() {
        let coinIDs = [Coin.btc.id, Coin.eth.id]
        let response = CoinMarketData.mock
        httpClient.getResponse = .success(try! JSONEncoder().encode(response))

        let expectation = XCTestExpectation(description: "Get market data for coin IDs")
        service.getMarketData(for: coinIDs)
            .sink(receiveCompletion: { result in
                switch result {
                case .failure(let error):
                    XCTFail("Failed to get market data: \(error.errorDescription ?? error.localizedDescription)")
                case .finished:
                    expectation.fulfill()
                }
            }, receiveValue: { value in
                XCTAssertFalse(value.isEmpty)
                XCTAssertEqual(value.count, response.count)

                XCTAssertEqual(value[coinIDs.first!]?.currentPrice, response[coinIDs.first!]?.currentPrice)
                XCTAssertEqual(value[coinIDs.first!]?.priceChange, response[coinIDs.first!]?.priceChange)

                XCTAssertEqual(value[coinIDs.last!]?.currentPrice, response[coinIDs.last!]?.currentPrice)
                XCTAssertEqual(value[coinIDs.last!]?.priceChange, response[coinIDs.last!]?.priceChange)
            })
            .store(in: &cancellables)

        wait(for: [expectation], timeout: 1)
    }
}
