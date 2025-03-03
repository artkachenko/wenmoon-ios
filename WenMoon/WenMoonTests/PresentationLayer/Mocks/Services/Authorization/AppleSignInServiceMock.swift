//
//  AppleSignInServiceMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 03.03.25.
//

import XCTest
import FirebaseAuth
@testable import WenMoon

class AppleSignInServiceMock: AppleSignInService {
    // MARK: - Properties
    var signInResult: Result<AuthCredential, Error>!
    
    // MARK: - GoogleSignInService
    func singIn() async throws -> AuthCredential {
        switch signInResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        case .none:
            XCTFail("signInResult not set")
            throw AuthError.failedToSignIn(provider: .apple)
        }
    }
}
