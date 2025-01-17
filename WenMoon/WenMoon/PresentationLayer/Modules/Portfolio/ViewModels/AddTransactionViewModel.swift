//
//  AddTransactionViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 27.12.24.
//

import Foundation

final class AddTransactionViewModel: BaseViewModel {
    // MARK: - Initializers
    init(swiftDataManager: SwiftDataManager? = nil) {
        super.init(swiftDataManager: swiftDataManager)
    }
    
    // MARK: - Internal Methods
    func shouldDisableAddTransactionsButton(for transaction: Transaction) -> Bool {
        switch transaction.type {
        case .buy, .sell:
            return (transaction.coinID == nil) || (transaction.quantity == nil) || (transaction.pricePerCoin == nil)
        default:
            return (transaction.coinID == nil) || (transaction.quantity == nil)
        }
    }
    
    func isPriceFieldRequired(for transactionType: Transaction.TransactionType) -> Bool {
        (transactionType == .buy) || (transactionType == .sell)
    }
}
