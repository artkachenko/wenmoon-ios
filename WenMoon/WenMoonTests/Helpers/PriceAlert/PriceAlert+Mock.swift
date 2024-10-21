//
//  PriceAlert+Mock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 21.10.24.
//

import Foundation
@testable import WenMoon

func makePriceAlert(
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

func makeBitcoinPriceAlert() -> PriceAlert {
    makePriceAlert(
        coinId: "bitcoin",
        coinName: "Bitcoin",
        targetPrice: 70000,
        targetDirection: .above
    )
}

func makeEthereumPriceAlert() -> PriceAlert {
    makePriceAlert(
        coinId: "ethereum",
        coinName: "Ethereum",
        targetPrice: 1000,
        targetDirection: .below
    )
}

func makePriceAlerts() -> [PriceAlert] {
    [makeBitcoinPriceAlert(), makeEthereumPriceAlert()]
}

func makeEmptyPriceAlerts() -> [PriceAlert] { [] }
