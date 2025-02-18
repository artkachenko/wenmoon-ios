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
        // Setup
        let transactions = Transaction.predefinedTransactions
        
        // Action
        viewModel.fetchPortfolios()
        
        // Assertions
        XCTAssertEqual(viewModel.portfolios.count, 1)
        XCTAssertEqual(viewModel.selectedPortfolio.transactions, transactions)
        XCTAssertTrue(swiftDataManager.insertMethodCalled)
        XCTAssertTrue(swiftDataManager.saveMethodCalled)
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
    
    func testAddTransaction() async {
        // Setup
        viewModel.selectedPortfolio = PortfolioFactoryMock.makePortfolio(transactions: [])
        let transaction = PortfolioFactoryMock.makeTransaction()
        let coin = CoinFactoryMock.makeCoin()
        
        // Action
        await viewModel.addTransaction(transaction, coin)
        
        // Assertions
        XCTAssertEqual(viewModel.selectedPortfolio.transactions.count, 1)
        XCTAssertEqual(viewModel.selectedPortfolio.transactions.first, transaction)
        XCTAssertTrue(swiftDataManager.insertMethodCalled)
        XCTAssertTrue(swiftDataManager.saveMethodCalled)
    }
    
    func testEditTransaction() {
        // Setup
        let transactionID = UUID().uuidString
        let coinID = "coin-1"
        let originalTransaction = PortfolioFactoryMock.makeTransaction(id: transactionID, coinID: coinID)
        viewModel.selectedPortfolio = PortfolioFactoryMock.makePortfolio(transactions: [originalTransaction])
        
        // Action
        let editedTransaction = PortfolioFactoryMock.makeTransaction(id: transactionID, coinID: coinID)
        viewModel.editTransaction(editedTransaction)
        
        // Assertions
        let transaction = viewModel.selectedPortfolio.transactions.first!
        XCTAssertEqual(transaction.quantity, editedTransaction.quantity)
        XCTAssertEqual(transaction.pricePerCoin, editedTransaction.pricePerCoin)
        XCTAssertEqual(transaction.date, editedTransaction.date)
        XCTAssertEqual(transaction.type, editedTransaction.type)
        XCTAssertTrue(swiftDataManager.saveMethodCalled)
    }
    
    func testDeleteTransactions() {
        // Setup
        let transactions = PortfolioFactoryMock.makeTransactions()
        viewModel.selectedPortfolio = PortfolioFactoryMock.makePortfolio(transactions: transactions)
        
        // Action
        viewModel.deleteTransactions(for: "coin-1")
        
        // Assertions
        XCTAssertTrue(viewModel.selectedPortfolio.transactions.isEmpty)
        XCTAssertTrue(swiftDataManager.saveMethodCalled)
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
        XCTAssertTrue(swiftDataManager.saveMethodCalled)
    }
    
    func testPortfolioCalculations() {
        // Setup
        let coinData1 = CoinFactoryMock.makeCoinData(id: "coin-1", currentPrice: 100, priceChangePercentage24H: 10)
        let coinData2 = CoinFactoryMock.makeCoinData(id: "coin-2", currentPrice: 200, priceChangePercentage24H: -5)
        let transaction1 = PortfolioFactoryMock.makeTransaction(coinID: coinData1.id, quantity: 10, pricePerCoin: 150, type: .buy)
        let transaction2 = PortfolioFactoryMock.makeTransaction(coinID: coinData2.id, quantity: 5, pricePerCoin: 300, type: .buy)
        viewModel.selectedPortfolio = PortfolioFactoryMock.makePortfolio(transactions: [transaction1, transaction2])
        swiftDataManager.fetchResult = [coinData1, coinData2]
        
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
        XCTAssertTrue(viewModel.isDeductiveTransaction(.sell))
        XCTAssertTrue(viewModel.isDeductiveTransaction(.transferOut))
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
