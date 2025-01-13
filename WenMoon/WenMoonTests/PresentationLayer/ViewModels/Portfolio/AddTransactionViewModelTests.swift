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
    var swiftDataManager: SwiftDataManagerMock!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        swiftDataManager = SwiftDataManagerMock()
        viewModel = AddTransactionViewModel(swiftDataManager: swiftDataManager)
    }
    
    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testCreateCoinData_withImage() async {
        // Setup
        let imageURL = URL(string: "https://example.com/image.png")!
        let coin = CoinFactoryMock.makeCoin(image: imageURL)
        
        // Action
        let createdCoin = await viewModel.createCoinData(from: coin)
        
        // Assertions
        assertCoinsEqual([coin], [createdCoin])
        XCTAssertNotNil(createdCoin.imageData)
    }
    
    func testCreateCoinData_withoutImage() async {
        // Setup
        let coin = CoinFactoryMock.makeCoin()
        
        // Action
        let createdCoin = await viewModel.createCoinData(from: coin)
        
        // Assertions
        assertCoinsEqual([coin], [createdCoin])
        XCTAssertNil(createdCoin.imageData)
    }
    
    func testShouldDisableAddTransactionsButton_buyAndSell() {
        // Setup
        let transaction = PortfolioFactoryMock.makeTransaction(type: .buy)
        
        // Action & Assertions
        XCTAssertFalse(viewModel.shouldDisableAddTransactionsButton(for: transaction))
        
        transaction.pricePerCoin = nil
        XCTAssert(viewModel.shouldDisableAddTransactionsButton(for: transaction))
        
        transaction.coin = nil
        XCTAssert(viewModel.shouldDisableAddTransactionsButton(for: transaction))
    }
    
    func testShouldDisableAddTransactionsButton_transferInAndOut() {
        // Setup
        let transaction = PortfolioFactoryMock.makeTransaction(type: .transferIn)
        
        // Action & Assertions
        XCTAssertFalse(viewModel.shouldDisableAddTransactionsButton(for: transaction))
        
        transaction.quantity = nil
        XCTAssert(viewModel.shouldDisableAddTransactionsButton(for: transaction))
        
        transaction.coin = nil
        XCTAssert(viewModel.shouldDisableAddTransactionsButton(for: transaction))
    }

    
    func testIsPriceFieldRequired() {
        // Action & Assertions
        XCTAssertTrue(viewModel.isPriceFieldRequired(for: .buy))
        XCTAssertTrue(viewModel.isPriceFieldRequired(for: .sell))

        XCTAssertFalse(viewModel.isPriceFieldRequired(for: .transferIn))
        XCTAssertFalse(viewModel.isPriceFieldRequired(for: .transferOut))
    }
}
