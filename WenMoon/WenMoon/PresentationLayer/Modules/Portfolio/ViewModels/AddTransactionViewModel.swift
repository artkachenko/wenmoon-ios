//
//  AddTransactionViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 27.12.24.
//

import Foundation

final class AddTransactionViewModel: BaseViewModel {
    // MARK: - Properties
    @Published var transaction: Transaction
    
    // MARK: - Initializers
    init(transaction: Transaction? = nil) {
        self.transaction = transaction ?? Transaction()
        super.init()
    }
    
    // MARK: - Internal Methods
    func makeCoinData(from coin: Coin) async -> CoinData {
        let imageData = (coin.image != nil) ? (await loadImage(from: coin.image!)) : nil
        return CoinData(from: coin, imageData: imageData)
    }
    
    func shouldDisableAddTransactionsButton() -> Bool {
        switch transaction.type {
        case .buy, .sell:
            return transaction.coin == nil || transaction.quantity == nil || transaction.pricePerCoin == nil
        default:
            return transaction.coin == nil || transaction.quantity == nil
        }
    }
}
