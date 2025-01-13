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
    func createCoinData(from coin: Coin) async -> CoinData {
        let imageData = (coin.image != nil) ? (await loadImage(from: coin.image!)) : nil
        return CoinData(from: coin, imageData: imageData)
    }
    
    func shouldDisableAddTransactionsButton(for transaction: Transaction) -> Bool {
        switch transaction.type {
        case .buy, .sell:
            return (transaction.coin == nil) || (transaction.quantity == nil) || (transaction.pricePerCoin == nil)
        default:
            return (transaction.coin == nil) || (transaction.quantity == nil)
        }
    }
    
    func isPriceFieldRequired(for transactionType: Transaction.TransactionType) -> Bool {
        (transactionType == .buy) || (transactionType == .sell)
    }
}
