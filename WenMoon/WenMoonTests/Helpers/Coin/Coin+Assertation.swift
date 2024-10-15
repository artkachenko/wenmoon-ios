//
//  Coin+Assertation.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 18.10.24.
//

import Foundation
import XCTest
@testable import WenMoon

func assertCoin(_ expected: Coin, _ actual: Coin) {
    XCTAssertEqual(expected.id, actual.id)
    XCTAssertEqual(expected.name, actual.name)
    XCTAssertEqual(expected.imageURL, actual.imageURL)
    XCTAssertEqual(expected.marketCapRank, actual.marketCapRank)
    XCTAssertEqual(expected.currentPrice, actual.currentPrice)
    XCTAssertEqual(expected.priceChangePercentage24H, actual.priceChangePercentage24H)
}

func assertCoin(_ expected: CoinData, _ actual: Coin, _ marketData: MarketData? = nil) {
    XCTAssertEqual(expected.id, actual.id)
    XCTAssertEqual(expected.name, actual.name)
    XCTAssertEqual(expected.imageURL, actual.imageURL)
    XCTAssertEqual(expected.rank, actual.marketCapRank)
    if let marketData {
        XCTAssertEqual(expected.currentPrice, marketData.currentPrice)
        XCTAssertEqual(expected.priceChange, marketData.priceChange)
    } else {
        XCTAssertEqual(expected.currentPrice, actual.currentPrice)
        XCTAssertEqual(expected.priceChange, actual.priceChangePercentage24H)
    }
}

func assertAPIFailure<T>(for apiCall: @escaping () async throws -> T, expectedError: APIError) async {
    do {
        _ = try await apiCall()
        XCTFail("Expected failure but got success")
    } catch let error as APIError {
        XCTAssertEqual(error, expectedError)
    } catch {
        XCTFail("Unexpected error: \(error)")
    }
}
