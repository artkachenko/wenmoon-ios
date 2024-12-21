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
    var coinToBeCompared: Coin!
    var coinToCompareWith: Coin!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        viewModel = CryptoCompareViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testCalculatePrice_now_success() {
        // Setup
        coinToBeCompared = CoinFactoryMock.makeCoin(circulatingSupply: 1_000)
        coinToCompareWith = CoinFactoryMock.makeCoin(marketCap: 100_000)
        
        // Action
        let price = viewModel.calculatePrice(for: coinToBeCompared, coinToCompareWith: coinToCompareWith, option: .now)
        
        // Assertions
        XCTAssertEqual(price, 100)
    }
    
    func testCalculatePrice_now_missingMarketCap() {
        // Setup
        coinToBeCompared = CoinFactoryMock.makeCoin(circulatingSupply: 1_000)
        coinToCompareWith = CoinFactoryMock.makeCoin(marketCap: nil)
        
        // Action
        let price = viewModel.calculatePrice(for: coinToBeCompared, coinToCompareWith: coinToCompareWith, option: .now)
        
        // Assertions
        XCTAssertNil(price)
    }
    
    func testCalculatePrice_ath_success() {
        // Setup
        coinToBeCompared = CoinFactoryMock.makeCoin(circulatingSupply: 500)
        coinToCompareWith = CoinFactoryMock.makeCoin(circulatingSupply: 1_000, ath: 200)
        
        // Action
        let price = viewModel.calculatePrice(for: coinToBeCompared, coinToCompareWith: coinToCompareWith, option: .ath)
        
        // Assertions
        XCTAssertEqual(price, 400)
    }
    
    func testCalculatePrice_ath_missingData() {
        // Setup
        coinToBeCompared = CoinFactoryMock.makeCoin(circulatingSupply: 500)
        coinToCompareWith = CoinFactoryMock.makeCoin(circulatingSupply: 1_000, ath: nil)
        
        // Action
        let price = viewModel.calculatePrice(for: coinToBeCompared, coinToCompareWith: coinToCompareWith, option: .ath)
        
        // Assertions
        XCTAssertNil(price)
    }
    
    func testCalculateMultiplier_success() {
        // Setup
        coinToBeCompared = CoinFactoryMock.makeCoin(currentPrice: 50, circulatingSupply: 1_000)
        coinToCompareWith = CoinFactoryMock.makeCoin(marketCap: 100_000)
        
        // Action
        let multiplier = viewModel.calculateMultiplier(for: coinToBeCompared, coinToCompareWith: coinToCompareWith, option: .now)
        
        // Assertions
        XCTAssertEqual(multiplier, 2)
    }
    
    func testCalculateMultiplier_failure() {
        // Setup
        coinToBeCompared = CoinFactoryMock.makeCoin(currentPrice: nil, circulatingSupply: 1_000)
        coinToCompareWith = CoinFactoryMock.makeCoin(marketCap: 100_000)
        
        // Action
        let multiplier = viewModel.calculateMultiplier(for: coinToBeCompared, coinToCompareWith: coinToCompareWith, option: .now)
        
        // Assertions
        XCTAssertNil(multiplier)
    }
    
    func testIsPositiveMultiplier() {
        // Assertions
        XCTAssert(viewModel.isPositiveMultiplier(2))
        XCTAssertFalse(viewModel.isPositiveMultiplier(0.5))
    }
}
