//
//  CryptoCompareViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 18.12.24.
//

import XCTest
@testable import WenMoon

class CryptoCompareViewModelTests: XCTestCase {
    // MARK: - Properties
    var viewModel: CryptoCompareViewModel!
    var coinScannerService: CoinScannerServiceMock!
    
    var coinA: Coin!
    var coinB: Coin!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        coinScannerService = CoinScannerServiceMock()
        viewModel = CryptoCompareViewModel(coinScannerService: coinScannerService)
    }
    
    override func tearDown() {
        viewModel = nil
        coinScannerService = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testUpdateCoinIfNeeded_noUpdateRequired() async {
        // Setup
        let coin = CoinFactoryMock.makeCoin()

        // Action
        let updatedCoin = await viewModel.updateCoinIfNeeded(coin)

        // Assertions
        XCTAssertEqual(updatedCoin.circulatingSupply, coin.circulatingSupply)
        XCTAssertEqual(updatedCoin.ath, coin.ath)
    }

    func testUpdateCoinIfNeeded_updateRequired_success() async {
        // Setup
        let coin = CoinFactoryMock.makeCoin(circulatingSupply: nil, ath: nil)
        let marketData = CoinDetailsFactoryMock.makeMarketData(circulatingSupply: 21_000_000, ath: 110_000)
        let response = CoinDetailsFactoryMock.makeCoinDetails(marketData: marketData)
        coinScannerService.getCoinDetailsResult = .success(response)

        // Action
        let updatedCoin = await viewModel.updateCoinIfNeeded(coin)

        // Assertions
        XCTAssertEqual(updatedCoin.circulatingSupply, marketData.circulatingSupply)
        XCTAssertEqual(updatedCoin.ath, marketData.ath)
    }

    func testUpdateCoinIfNeeded_updateRequired_apiError() async {
        // Setup
        let coin = CoinFactoryMock.makeCoin(circulatingSupply: nil, ath: nil)
        let error = ErrorFactoryMock.makeAPIError()
        coinScannerService.getCoinDetailsResult = .failure(error)

        // Action
        let updatedCoin = await viewModel.updateCoinIfNeeded(coin)

        // Assertions
        XCTAssertNil(updatedCoin.circulatingSupply)
        XCTAssertNil(updatedCoin.ath)
    }
    
    func testCalculatePrice_now_success() {
        // Setup
        coinA = CoinFactoryMock.makeCoin(circulatingSupply: 1_000)
        coinB = CoinFactoryMock.makeCoin(marketCap: 100_000)
        
        // Action
        let price = viewModel.calculatePrice(for: coinA, coinB: coinB, option: .now)
        
        // Assertions
        XCTAssertEqual(price, 100)
    }
    
    func testCalculatePrice_now_missingMarketCap() {
        // Setup
        coinA = CoinFactoryMock.makeCoin(circulatingSupply: 1_000)
        coinB = CoinFactoryMock.makeCoin(marketCap: nil)
        
        // Action
        let price = viewModel.calculatePrice(for: coinA, coinB: coinB, option: .now)
        
        // Assertions
        XCTAssertNil(price)
    }
    
    func testCalculatePrice_ath_success() {
        // Setup
        coinA = CoinFactoryMock.makeCoin(circulatingSupply: 500)
        coinB = CoinFactoryMock.makeCoin(circulatingSupply: 1_000, ath: 200)
        
        // Action
        let price = viewModel.calculatePrice(for: coinA, coinB: coinB, option: .ath)
        
        // Assertions
        XCTAssertEqual(price, 400)
    }
    
    func testCalculatePrice_ath_missingData() {
        // Setup
        coinA = CoinFactoryMock.makeCoin(circulatingSupply: 500)
        coinB = CoinFactoryMock.makeCoin(circulatingSupply: 1_000, ath: nil)
        
        // Action
        let price = viewModel.calculatePrice(for: coinA, coinB: coinB, option: .ath)
        
        // Assertions
        XCTAssertNil(price)
    }
    
    func testCalculateMultiplier_success() {
        // Setup
        coinA = CoinFactoryMock.makeCoin(currentPrice: 50, circulatingSupply: 1_000)
        coinB = CoinFactoryMock.makeCoin(marketCap: 100_000)
        
        // Action
        let multiplier = viewModel.calculateMultiplier(for: coinA, coinB: coinB, option: .now)
        
        // Assertions
        XCTAssertEqual(multiplier, 2)
    }
    
    func testCalculateMultiplier_failure() {
        // Setup
        coinA = CoinFactoryMock.makeCoin(currentPrice: nil, circulatingSupply: 1_000)
        coinB = CoinFactoryMock.makeCoin(marketCap: 100_000)
        
        // Action
        let multiplier = viewModel.calculateMultiplier(for: coinA, coinB: coinB, option: .now)
        
        // Assertions
        XCTAssertNil(multiplier)
    }
    
    func testIsPositiveMultiplier() {
        // Non-finite values
        XCTAssertNil(viewModel.isPositiveMultiplier(.infinity))
        XCTAssertNil(viewModel.isPositiveMultiplier(-.infinity))
        XCTAssertNil(viewModel.isPositiveMultiplier(.nan))
        
        // Values close to zero (within tolerance of 0.01)
        XCTAssertNil(viewModel.isPositiveMultiplier(.zero))
        XCTAssertNil(viewModel.isPositiveMultiplier(0.0099))
        
        // Values exactly at and beyond the tolerance boundary
        XCTAssertFalse(viewModel.isPositiveMultiplier(0.01)!)
        XCTAssertFalse(viewModel.isPositiveMultiplier(0.5)!)
        XCTAssertFalse(viewModel.isPositiveMultiplier(0.98)!)
        
        // Values close to one (within tolerance of 0.01)
        XCTAssertNil(viewModel.isPositiveMultiplier(1.0099))
        XCTAssertNil(viewModel.isPositiveMultiplier(0.9999))
        
        // Values exactly at and beyond the tolerance boundary
        XCTAssertFalse(viewModel.isPositiveMultiplier(0.99)!)
        XCTAssertTrue(viewModel.isPositiveMultiplier(1.01)!)
        XCTAssertTrue(viewModel.isPositiveMultiplier(1.02)!)
        
        // Positive multipliers (greater than 1, outside tolerance)
        XCTAssertTrue(viewModel.isPositiveMultiplier(2)!)
    }
}
