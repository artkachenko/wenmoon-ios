//
//  CoinMarketsViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 14.02.25.
//

import XCTest
@testable import WenMoon

final class CoinMarketsViewModelTests: XCTestCase {
    // MARK: - Properties
    var viewModel: CoinMarketsViewModel!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        let tickers = CoinDetailsFactoryMock.makeCoinTickers()
        viewModel = CoinMarketsViewModel(tickers: tickers)
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    // MARK: - Tests
    func testSearchedTickers_SortedByVolumeDescending() {
        // Assertions
        let sortedTickers = viewModel.searchedTickers
        let volumes = sortedTickers.compactMap { $0.convertedVolume }
        XCTAssertEqual(volumes, volumes.sorted(by: >))
    }

    func testSearchedTickers_FilterByMarketName() {
        // Action
        viewModel.searchText = "Binance"
        // Assertions
        let results = viewModel.searchedTickers
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.market.name!.contains("Binance") })
    }

    func testSearchedTickers_FilterByMarketID() {
        // Action
        viewModel.searchText = "kraken"
        // Assertions
        let results = viewModel.searchedTickers
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.market.identifier!.contains("kraken") })
    }

    func testSearchedTickers_emptySearch() {
        // Action
        viewModel.searchText = ""
        // Assertions
        XCTAssertEqual(viewModel.searchedTickers.count, 5)
    }

    func testSearchedTickers_caseInsensitive() {
        // Action
        viewModel.searchText = "COINBASE"
        // Assertions
        let results = viewModel.searchedTickers
        XCTAssertFalse(results.isEmpty)
        XCTAssertTrue(results.allSatisfy { $0.market.name!.localizedCaseInsensitiveContains("coinbase") })
    }

    func testSearchedTickers_emptyResults() {
        // Action
        viewModel.searchText = "unknown"
        // Assertions
        XCTAssertEqual(viewModel.searchedTickers.count, .zero)
    }
}
