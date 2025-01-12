//
//  PortfolioViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 05.12.24.
//

import Foundation
import SwiftData

final class PortfolioViewModel: BaseViewModel {
    // MARK: - Nested Types
    enum Timeline: String {
        case twentyFourHours = "24h"
        case allTime = "All Time"
    }
    
    // MARK: - Properties
    @Published var groupedTransactions: [CoinTransactions] = []
    @Published var totalValue: Double = .zero
    @Published var portfolioChange24HValue: Double = .zero
    @Published var portfolioChange24HPercentage: Double = .zero
    @Published var portfolioChangeAllTimeValue: Double = .zero
    @Published var portfolioChangeAllTimePercentage: Double = .zero
    @Published var selectedTimeline: Timeline = .twentyFourHours
    
    var portfolios: [Portfolio] = []
    var selectedPortfolio: Portfolio!
    
    var portfolioChangePercentage: Double {
        switch selectedTimeline {
        case .twentyFourHours:
            return portfolioChange24HPercentage
        case .allTime:
            return portfolioChangeAllTimePercentage
        }
    }
    
    var portfolioChangeValue: Double {
        switch selectedTimeline {
        case .twentyFourHours:
            return portfolioChange24HValue
        case .allTime:
            return portfolioChangeAllTimeValue
        }
    }
    
    // MARK: - Initializers
    init(swiftDataManager: SwiftDataManager? = nil) {
        super.init(swiftDataManager: swiftDataManager)
    }
    
    // MARK: - Internal Methods
    func fetchPortfolios() {
        let descriptor = FetchDescriptor<Portfolio>()
        let fetchedPortfolios = fetch(descriptor)
        
        if fetchedPortfolios.isEmpty {
            let newPortfolio = Portfolio()
            portfolios.append(newPortfolio)
            selectedPortfolio = newPortfolio
            insert(newPortfolio)
        } else {
            portfolios = fetchedPortfolios
            selectedPortfolio = fetchedPortfolios.first
        }
        updateAndSavePortfolio()
    }
    
    func addTransaction(_ transaction: Transaction) {
        let existingQuantity = groupedTransactions.first { $0.coin.id == transaction.coin?.id }?.totalQuantity ?? .zero
        let quantity = transaction.quantity ?? .zero
        
        if (transaction.type == .sell || transaction.type == .transferOut) && quantity > existingQuantity { return }
        
        selectedPortfolio.transactions.append(transaction)
        updateAndSavePortfolio()
    }
    
    func editTransaction(_ transaction: Transaction) {
        guard let index = selectedPortfolio.transactions.firstIndex(where: { $0.id == transaction.id }) else {
            return
        }
        
        let existingTransaction = selectedPortfolio.transactions[index]
        let existingQuantity = groupedTransactions
            .first { $0.coin.id == transaction.coin?.id }?.totalQuantity ?? 0
        let newQuantity = transaction.quantity ?? .zero
        let deltaQuantity = newQuantity - (existingTransaction.quantity ?? .zero)
        
        if (transaction.type == .sell || transaction.type == .transferOut) && deltaQuantity > existingQuantity { return }
        
        selectedPortfolio.transactions[index] = transaction
        updateAndSavePortfolio()
    }
    
    func deleteTransactions(for coinID: String) {
        let transactionsToDelete = selectedPortfolio.transactions.filter { $0.coin?.id == coinID }
        transactionsToDelete.forEach { transaction in
            delete(transaction)
        }
        selectedPortfolio.transactions.removeAll { $0.coin?.id == coinID }
        updateAndSavePortfolio()
    }

    func deleteTransaction(_ transactionID: String) {
        guard let transactionToDelete = selectedPortfolio.transactions.first(where: { $0.id == transactionID }) else {
            return
        }
        delete(transactionToDelete)
        selectedPortfolio.transactions.removeAll { $0.id == transactionID }
        updateAndSavePortfolio()
    }
    
    func updatePortfolio() {
        groupedTransactions = groupTransactionsByCoin(selectedPortfolio.transactions)
        totalValue = calculateTotalValue()
        calculatePortfolio24HChanges()
        calculatePortfolioChanges()
    }
    
    func isDeductiveTransaction(_ transactionType: Transaction.TransactionType) -> Bool {
        (transactionType == .sell) || (transactionType == .transferOut)
    }
    
    func toggleSelectedTimeline() {
        selectedTimeline = (selectedTimeline == .twentyFourHours) ? .allTime : .twentyFourHours
    }
    
    // MARK: - Private Methods
    private func updateAndSavePortfolio() {
        updatePortfolio()
        save()
    }
    
    private func groupTransactionsByCoin(_ transactions: [Transaction]) -> [CoinTransactions] {
        let groupedTransactions = Dictionary(grouping: transactions) { $0.coin?.id }
        return groupedTransactions.compactMap { coinID, transactions in
            guard let coin = transactions.first?.coin else { return nil }
            return CoinTransactions(coin: coin, transactions: transactions)
        }
        .sorted { $0.totalValue > $1.totalValue }
    }
    
    private func calculateTotalValue() -> Double {
        groupedTransactions.reduce(0) { total, group in
            total + group.totalValue
        }
    }
    
    private func calculatePortfolio24HChanges() {
        var total24HChange: Double = .zero
        var previousTotalValue: Double = .zero

        groupedTransactions.forEach { coinTransaction in
            guard let currentPrice = coinTransaction.coin.currentPrice,
                  let priceChangePercentage24H = coinTransaction.coin.priceChangePercentage24H else {
                return
            }
            
            let totalQuantity = coinTransaction.totalQuantity
            let coinValue24HChange = totalQuantity * currentPrice * (priceChangePercentage24H / 100)
            total24HChange += coinValue24HChange
            
            let previousCoinValue = totalQuantity * currentPrice / (1 + priceChangePercentage24H / 100)
            previousTotalValue += previousCoinValue
        }
        
        portfolioChange24HValue = total24HChange
        portfolioChange24HPercentage = (previousTotalValue > .zero) ? (total24HChange / previousTotalValue) * 100 : .zero
    }
    
    private func calculatePortfolioChanges() {
        var initialInvestment: Double = .zero
        var realizedValue: Double = .zero
        var remainingQuantity: Double = .zero
        
        selectedPortfolio.transactions.forEach { transaction in
            let quantity = transaction.quantity ?? .zero
            let pricePerCoin = transaction.pricePerCoin ?? .zero
            
            switch transaction.type {
            case .buy:
                initialInvestment += quantity * pricePerCoin
                remainingQuantity += quantity
            case .sell:
                if remainingQuantity > .zero {
                    realizedValue += quantity * pricePerCoin
                    remainingQuantity -= quantity
                }
            case .transferIn:
                remainingQuantity += quantity
            case .transferOut:
                if remainingQuantity > .zero {
                    remainingQuantity -= quantity
                }
            }
        }
        
        portfolioChangeAllTimeValue = (totalValue + realizedValue) - initialInvestment
        portfolioChangeAllTimePercentage = (initialInvestment > .zero) ? ((portfolioChangeAllTimeValue / initialInvestment) * 100) : .zero
    }
}

struct CoinTransactions: Equatable {
    let coin: CoinData
    let transactions: [Date: [Transaction]]
    
    var totalQuantity: Double {
        transactions.values.flatMap { $0 }.reduce(0) { total, transaction in
            guard let quantity = transaction.quantity else { return total }
            switch transaction.type {
            case .buy, .transferIn:
                return total + quantity
            case .sell, .transferOut:
                return total - quantity
            }
        }
    }
    
    var totalValue: Double {
        guard let currentPrice = coin.currentPrice else { return .zero }
        return totalQuantity * currentPrice
    }
    
    init(coin: CoinData, transactions: [Transaction]) {
        self.coin = coin
        let groupedByDate = Dictionary(grouping: transactions) { transaction in
            Calendar.current.startOfDay(for: transaction.date)
        }
        self.transactions = groupedByDate.mapValues { transactions in
            transactions.sorted { $0.date > $1.date }
        }
    }
}
