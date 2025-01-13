//
//  PortfolioViewModelTests.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 11.01.25.
//

import XCTest
@testable import WenMoon

final class PortfolioViewModelTests: XCTestCase {
    // MARK: - Properties
    var viewModel: PortfolioViewModel!
    var swiftDataManager: SwiftDataManagerMock!
    
    // MARK: - Setup
    override func setUp() {
        super.setUp()
        swiftDataManager = SwiftDataManagerMock()
        viewModel = PortfolioViewModel(swiftDataManager: swiftDataManager)
    }
    
    override func tearDown() {
        viewModel = nil
        swiftDataManager = nil
        super.tearDown()
    }
    
    // MARK: - Tests
    func testFetchPortfolios_createsNewPortfolio() {
        // Action
        viewModel.fetchPortfolios()
        
        // Assertions
        XCTAssertEqual(viewModel.portfolios.count, 1)
        XCTAssertNotNil(viewModel.selectedPortfolio)
        XCTAssert(swiftDataManager.insertMethodCalled)
        XCTAssert(swiftDataManager.saveMethodCalled)
    }
    
    func testFetchPortfolios_fetchesExistingPortfolios() {
        // Setup
        let portfolio = PortfolioFactoryMock.makePortfolio()
        swiftDataManager.fetchResult = [portfolio]
        
        // Action
        viewModel.fetchPortfolios()
        
        // Assertions
        XCTAssertEqual(viewModel.portfolios.count, 1)
        XCTAssertEqual(viewModel.selectedPortfolio, portfolio)
    }
    
    func testAddTransaction() {
        // Setup
        viewModel.selectedPortfolio = PortfolioFactoryMock.makePortfolio(transactions: [])
        let transaction = PortfolioFactoryMock.makeTransaction()
        
        // Action
        viewModel.addTransaction(transaction)
        
        // Assertions
        XCTAssertEqual(viewModel.selectedPortfolio.transactions.count, 1)
        XCTAssertEqual(viewModel.selectedPortfolio.transactions.first, transaction)
        XCTAssert(swiftDataManager.saveMethodCalled)
    }
    
    func testEditTransaction() {
        // Setup
        let transactionID = UUID().uuidString
        let originalTransaction = PortfolioFactoryMock.makeTransaction(id: transactionID)
        viewModel.selectedPortfolio = PortfolioFactoryMock.makePortfolio(transactions: [originalTransaction])
        let editedTransaction = PortfolioFactoryMock.makeTransaction(id: transactionID)
        
        // Action
        viewModel.editTransaction(editedTransaction)
        
        // Assertions
        XCTAssertEqual(viewModel.selectedPortfolio.transactions.first, editedTransaction)
        XCTAssert(swiftDataManager.saveMethodCalled)
    }
    
    func testDeleteTransactions() {
        // Setup
        let coin = CoinFactoryMock.makeCoinData()
        let transactions = PortfolioFactoryMock.makeTransactions(coin: coin)
        viewModel.selectedPortfolio = PortfolioFactoryMock.makePortfolio(transactions: transactions)
        
        // Action
        viewModel.deleteTransactions(for: coin.id)
        
        // Assertions
        XCTAssert(viewModel.selectedPortfolio.transactions.isEmpty)
        XCTAssert(swiftDataManager.deleteMethodCalled)
        XCTAssert(swiftDataManager.saveMethodCalled)
    }
    
    func testDeleteTransaction() {
        // Setup
        let transactionID = UUID().uuidString
        let transaction1 = PortfolioFactoryMock.makeTransaction(id: transactionID)
        let transaction2 = PortfolioFactoryMock.makeTransaction()
        viewModel.selectedPortfolio = PortfolioFactoryMock.makePortfolio(transactions: [transaction1, transaction2])
        
        // Action
        viewModel.deleteTransaction(transactionID)
        
        // Assertions
        XCTAssertEqual(viewModel.selectedPortfolio.transactions.count, 1)
        XCTAssertEqual(viewModel.selectedPortfolio.transactions.first, transaction2)
        XCTAssert(swiftDataManager.deleteMethodCalled)
        XCTAssert(swiftDataManager.saveMethodCalled)
    }
    
    func testPortfolioCalculations() {
        // Setup
        let coinData1 = CoinFactoryMock.makeCoinData(
            from: CoinFactoryMock.makeCoin(id: "coin-1", currentPrice: 100, priceChangePercentage24H: 10)
        )
        let coinData2 = CoinFactoryMock.makeCoinData(
            from: CoinFactoryMock.makeCoin(id: "coin-2", currentPrice: 200, priceChangePercentage24H: -5)
        )
        let transaction1 = PortfolioFactoryMock.makeTransaction(coin: coinData1, quantity: 10, pricePerCoin: 150, type: .buy)
        let transaction2 = PortfolioFactoryMock.makeTransaction(coin: coinData2, quantity: 5, pricePerCoin: 300, type: .buy)
        viewModel.selectedPortfolio = PortfolioFactoryMock.makePortfolio(transactions: [transaction1, transaction2])
        
        // Action
        viewModel.updatePortfolio()
        
        // Assertions
        XCTAssertEqual(viewModel.totalValue, 2_000)
        XCTAssertEqual(viewModel.portfolioChange24HValue, 50)
        XCTAssertEqual(viewModel.portfolioChange24HPercentage, 2.55, accuracy: 0.01)
        XCTAssertEqual(viewModel.portfolioChangeAllTimeValue, -1_000)
        XCTAssertEqual(viewModel.portfolioChangeAllTimePercentage, -33.33, accuracy: 0.01)
    }
    
    func testIsDeductiveTransaction() {
        // Assertions
        XCTAssert(viewModel.isDeductiveTransaction(.sell))
        XCTAssert(viewModel.isDeductiveTransaction(.transferOut))
        XCTAssertFalse(viewModel.isDeductiveTransaction(.buy))
        XCTAssertFalse(viewModel.isDeductiveTransaction(.transferIn))
    }
    
    
    func testToggleSelectedTimeline() {
        // Setup
        XCTAssertEqual(viewModel.selectedTimeline, .twentyFourHours)
        
        // Action & Assertions
        viewModel.toggleSelectedTimeline()
        XCTAssertEqual(viewModel.selectedTimeline, .allTime)
        
        viewModel.toggleSelectedTimeline()
        XCTAssertEqual(viewModel.selectedTimeline, .twentyFourHours)
    }
}
