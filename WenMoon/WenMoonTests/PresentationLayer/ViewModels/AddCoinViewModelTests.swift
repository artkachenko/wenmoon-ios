//
//  AddCoinViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.04.23.
//

import XCTest
@testable import WenMoon

@MainActor
class AddCoinViewModelTests: XCTestCase {

    // MARK: - Properties
    var viewModel: AddCoinViewModel!
    var service: CoinScannerServiceMock!

    // MARK: - Setup
    override func setUp() {
        super.setUp()
        service = CoinScannerServiceMock()
        viewModel = AddCoinViewModel(coinScannerService: service)
    }

    override func tearDown() {
        viewModel = nil
        service = nil
        super.tearDown()
    }

    // MARK: - Tests
    func testFetchCoinsSuccess() async throws {
        let response = makeCoins()
        service.getCoinsAtPageResult = .success(response)

        await viewModel.fetchCoins()

        let coins = viewModel.coins
        XCTAssertFalse(coins.isEmpty)
        XCTAssertEqual(coins.count, response.count)

        assertCoin(coins.first!, response.first!)
        assertCoin(coins.last!, response.last!)

        XCTAssertNil(viewModel.errorMessage)
    }

    func testFetchCoinsFailure() async throws {
        let apiError: APIError = .apiError(description: "Mocked server error")
        service.getCoinsAtPageResult = .failure(apiError)

        await viewModel.fetchCoins()

        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, apiError.errorDescription)
    }

    func testSearchCoinsByQuerySuccess() async throws {
        let response = makeCoins()
        service.searchCoinsByQueryResult = .success(response)

        await viewModel.searchCoins(for: "bit")

        let coins = viewModel.coins
        XCTAssertFalse(coins.isEmpty)
        XCTAssertEqual(coins.count, response.count)

        assertCoin(coins.first!, response.first!)
        assertCoin(coins.last!, response.last!)

        XCTAssertNil(viewModel.errorMessage)
    }

    func testSearchCoinsByQueryEmptyResult() async throws {
        let response = makeEmptyCoins()
        service.searchCoinsByQueryResult = .success(response)

        await viewModel.searchCoins(for: "sdfghjkl")

        XCTAssertTrue(viewModel.coins.isEmpty)
        XCTAssertNil(viewModel.errorMessage)
    }
}
