//
//  Error+Assertations.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 24.10.24.
//

import Foundation
import XCTest
@testable import WenMoon

func assertFailure<T>(for apiCall: @escaping () async throws -> T, expectedError: APIError) async {
    do {
        _ = try await apiCall()
        XCTFail("Expected failure but got success")
    } catch let error as APIError {
        XCTAssertEqual(error, expectedError)
    } catch {
        XCTFail("Unexpected error: \(error)")
    }
}
