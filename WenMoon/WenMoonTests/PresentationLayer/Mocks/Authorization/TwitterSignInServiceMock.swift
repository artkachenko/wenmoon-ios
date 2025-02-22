//
//  TwitterSignInServiceMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 02.12.24.
//

import XCTest
import FirebaseAuth
@testable import WenMoon

class TwitterSignInServiceMock: TwitterSignInService {
    // MARK: - Properties
    var signInResult: Result<FirebaseAuth.AuthCredential, Error>!
    
    // MARK: - TwitterSignInService
    func signIn() async throws -> AuthCredential? {
        switch signInResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        case .none:
            XCTFail("signInResult not set")
            return nil
        }
    }
}
