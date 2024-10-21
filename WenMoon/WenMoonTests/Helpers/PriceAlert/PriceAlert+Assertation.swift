//
//  PriceAlert+Assertation.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 21.10.24.
//

import Foundation
import XCTest
@testable import WenMoon

func assertPriceAlert(_ expected: PriceAlert, _ actual: PriceAlert) {
    XCTAssertEqual(expected.coinId, actual.coinId)
    XCTAssertEqual(expected.coinName, actual.coinName)
    XCTAssertEqual(expected.targetPrice, actual.targetPrice)
    XCTAssertEqual(expected.targetDirection, actual.targetDirection)
}
