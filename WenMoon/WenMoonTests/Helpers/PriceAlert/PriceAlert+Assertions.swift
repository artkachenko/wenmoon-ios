//
//  PriceAlert+Assertions.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 21.10.24.
//

import Foundation
import XCTest
@testable import WenMoon

func assertPriceAlertsEqual(_ priceAlerts: [PriceAlert], _ expectedPriceAlerts: [PriceAlert]) {
    XCTAssertEqual(priceAlerts.count, expectedPriceAlerts.count)
    for (index, _) in priceAlerts.enumerated() {
        let priceAlert = priceAlerts[index]
        let expectedPriceAlert = expectedPriceAlerts[index]
        XCTAssertEqual(priceAlert.coinId, expectedPriceAlert.coinId)
        XCTAssertEqual(priceAlert.coinName, expectedPriceAlert.coinName)
        XCTAssertEqual(priceAlert.targetPrice, expectedPriceAlert.targetPrice)
        XCTAssertEqual(priceAlert.targetDirection, expectedPriceAlert.targetDirection)
    }
}

func assertCoinHasAlert(_ coin: CoinData, _ targetPrice: Double) {
    XCTAssertEqual(coin.targetPrice, targetPrice)
    XCTAssert(coin.isActive)
}

func assertCoinHasNoAlert(_ coin: CoinData) {
    XCTAssertNil(coin.targetPrice)
    XCTAssertFalse(coin.isActive)
}
