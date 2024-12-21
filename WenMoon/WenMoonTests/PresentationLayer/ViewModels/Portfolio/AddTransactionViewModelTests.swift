//
//  AddTransactionViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 11.01.25.
//

import XCTest
@testable import WenMoon

final class AddTransactionViewModelTests: XCTestCase {
    // MARK: - Properties
    var viewModel: AddTransactionViewModel!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        viewModel = AddTransactionViewModel()
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testMakeCoinData_withImage() async {
        // Setup
        let imageURL = URL(string: "https://example.com/image.png")!
        let coin = CoinFactoryMock.makeCoin(image: imageURL)
        
        // Action
        let coinData = await viewModel.makeCoinData(from: coin)
        
        // Assertions
        assertCoinsEqual([coin], [coinData])
        XCTAssertNotNil(coinData.imageData)
    }
    
    func testMakeCoinData_withoutImage() async {
        // Setup
        let coin = CoinFactoryMock.makeCoin()
        
        // Action
        let coinData = await viewModel.makeCoinData(from: coin)
        
        // Assertions
        assertCoinsEqual([coin], [coinData])
        XCTAssertNil(coinData.imageData)
    }
    
    func testShouldDisableAddTransactionsButton_buyAndSell() {
        // Setup
        viewModel.transaction = PortfolioFactoryMock.makeTransaction(type: .buy)
        
        // Action & Assertions
        XCTAssertFalse(viewModel.shouldDisableAddTransactionsButton())
        
        viewModel.transaction.pricePerCoin = nil
        XCTAssert(viewModel.shouldDisableAddTransactionsButton())
        
        viewModel.transaction.coin = nil
        XCTAssert(viewModel.shouldDisableAddTransactionsButton())
    }
    
    func testShouldDisableAddTransactionsButton_transferInAndOut() {
        // Setup
        viewModel.transaction = PortfolioFactoryMock.makeTransaction(type: .transferIn)
        
        // Action & Assertions
        XCTAssertFalse(viewModel.shouldDisableAddTransactionsButton())
        
        viewModel.transaction.quantity = nil
        XCTAssert(viewModel.shouldDisableAddTransactionsButton())
        
        viewModel.transaction.coin = nil
        XCTAssert(viewModel.shouldDisableAddTransactionsButton())
    }
}
