//
//  Transaction.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 26.12.24.
//

import Foundation
import SwiftData

@Model
final class Transaction: Identifiable {
    enum TransactionType: String, Codable, CaseIterable {
        case buy = "Buy"
        case sell = "Sell"
        case transferIn = "Transfer In"
        case transferOut = "Transfer Out"
    }
    
    @Attribute(.unique)
    var id: String
    var coinID: String?
    var quantity: Double?
    var pricePerCoin: Double?
    var date: Date
    var type: TransactionType
    
    init(
        id: String = UUID().uuidString,
        coinID: String? = nil,
        quantity: Double? = nil,
        pricePerCoin: Double? = nil,
        date: Date = .now,
        type: TransactionType = .buy
    ) {
        self.id = id
        self.coinID = coinID
        self.quantity = quantity
        self.pricePerCoin = pricePerCoin
        self.date = date
        self.type = type
    }
    
    var totalCost: Double {
        guard
            let quantity,
            let pricePerCoin,
            type == .buy || type == .sell
        else {
            return .zero
        }
        return quantity * pricePerCoin
    }
    
    func update(from transaction: Transaction) {
        quantity = transaction.quantity
        pricePerCoin = transaction.pricePerCoin
        date = transaction.date
        type = transaction.type
    }
}

extension Transaction {
    func copy() -> Transaction {
        Transaction(
            id: id,
            coinID: coinID,
            quantity: quantity,
            pricePerCoin: pricePerCoin,
            date: date,
            type: type
        )
    }
}
