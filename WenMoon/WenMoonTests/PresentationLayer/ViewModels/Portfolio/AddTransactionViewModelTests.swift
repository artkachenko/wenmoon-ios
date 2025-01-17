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
    func testShouldDisableAddTransactionsButton_buyAndSell() {
        // Setup
        let transaction = PortfolioFactoryMock.makeTransaction(type: .buy)
        
        // Action & Assertions
        XCTAssertFalse(viewModel.shouldDisableAddTransactionsButton(for: transaction))
        
        transaction.pricePerCoin = nil
        XCTAssertTrue(viewModel.shouldDisableAddTransactionsButton(for: transaction))
        
        transaction.coinID = nil
        XCTAssertTrue(viewModel.shouldDisableAddTransactionsButton(for: transaction))
    }
    
    func testShouldDisableAddTransactionsButton_transferInAndOut() {
        // Setup
        let transaction = PortfolioFactoryMock.makeTransaction(type: .transferIn)
        
        // Action & Assertions
        XCTAssertFalse(viewModel.shouldDisableAddTransactionsButton(for: transaction))
        
        transaction.quantity = nil
        XCTAssertTrue(viewModel.shouldDisableAddTransactionsButton(for: transaction))
        
        transaction.coinID = nil
        XCTAssertTrue(viewModel.shouldDisableAddTransactionsButton(for: transaction))
    }

    
    func testIsPriceFieldRequired() {
        // Action & Assertions
        XCTAssertTrue(viewModel.isPriceFieldRequired(for: .buy))
        XCTAssertTrue(viewModel.isPriceFieldRequired(for: .sell))

        XCTAssertFalse(viewModel.isPriceFieldRequired(for: .transferIn))
        XCTAssertFalse(viewModel.isPriceFieldRequired(for: .transferOut))
    }
}
