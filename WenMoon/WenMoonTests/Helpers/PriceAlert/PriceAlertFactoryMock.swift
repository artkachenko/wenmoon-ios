//
//  PriceAlertFactoryMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 21.10.24.
//

import Foundation
@testable import WenMoon

struct PriceAlertFactoryMock {
    static func makePriceAlert(
        coinId: String = "coin-1",
        coinName: String = "Coin 1",
        targetPrice: Double = .random(in: 0.01...100_000),
        targetDirection: PriceAlert.TargetDirection = Bool.random() ? .above : .below
    ) -> PriceAlert {
        .init(
            coinId: coinId,
            coinName: coinName,
            targetPrice: targetPrice,
            targetDirection: targetDirection
        )
    }
    
    static func makePriceAlerts(count: Int = 10) -> [PriceAlert] {
        (1...count).map { index in
            makePriceAlert(
                coinId: "coin-\(index)",
                coinName: "Coin \(index)"
            )
        }
    }
}
