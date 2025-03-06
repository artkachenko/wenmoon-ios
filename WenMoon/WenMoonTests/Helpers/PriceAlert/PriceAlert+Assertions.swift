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
        XCTAssertEqual(priceAlert, expectedPriceAlert)
    }
}

func assertCoinHasActiveAlert(_ coin: CoinData, _ priceAlert: PriceAlert) {
    XCTAssertFalse(coin.priceAlerts.isEmpty)
    XCTAssertTrue(coin.priceAlerts.contains(priceAlert))
}

func assertCoinHasNoActiveAlert(_ coin: CoinData) {
    XCTAssertTrue(coin.priceAlerts.filter(\.isActive).isEmpty)
}

func assertCoinHasNoAlert(_ coin: CoinData) {
    XCTAssertTrue(coin.priceAlerts.isEmpty)
}
