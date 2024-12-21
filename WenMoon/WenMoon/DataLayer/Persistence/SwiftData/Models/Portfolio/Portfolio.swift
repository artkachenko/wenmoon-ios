//
//  Portfolio.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 26.12.24.
//

import Foundation
import SwiftData

@Model
final class Portfolio {
    @Attribute(.unique)
    var id: String
    var name: String
    @Relationship(deleteRule: .cascade)
    var transactions: [Transaction]
    
    init(id: String = UUID().uuidString, name: String = "Main", transactions: [Transaction] = []) {
        self.id = id
        self.name = name
        self.transactions = transactions
    }
}
