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
        coinId: String,
        coinName: String,
        targetPrice: Double,
        targetDirection: PriceAlert.TargetDirection
    ) -> PriceAlert {
        .init(
            coinId: coinId,
            coinName: coinName,
            targetPrice: targetPrice,
            targetDirection: targetDirection
        )
    }
    
    static func makeBitcoinPriceAlert() -> PriceAlert {
        makePriceAlert(
            coinId: "bitcoin",
            coinName: "Bitcoin",
            targetPrice: 70000,
            targetDirection: .above
        )
    }
    
    static func makeEthereumPriceAlert() -> PriceAlert {
        makePriceAlert(
            coinId: "ethereum",
            coinName: "Ethereum",
            targetPrice: 1000,
            targetDirection: .below
        )
    }
    
    static func makePriceAlerts() -> [PriceAlert] {
        [makeBitcoinPriceAlert(), makeEthereumPriceAlert()]
    }
    
    static func makeEmptyPriceAlerts() -> [PriceAlert] { [] }
}
