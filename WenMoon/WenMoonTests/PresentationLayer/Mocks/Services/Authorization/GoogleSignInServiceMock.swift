//
//  GoogleSignInServiceMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 02.12.24.
//

import XCTest
import FirebaseAuth
import GoogleSignIn
@testable import WenMoon

class GoogleSignInServiceMock: GoogleSignInService {
    // MARK: - Properties
    var clientID: String!
    var signInResult: Result<GIDSignInResult, Error>!
    
    // MARK: - GoogleSignInService
    func configure(clientID: String) {
        self.clientID = clientID
    }
    
    func signIn(withPresenting viewController: UIViewController) async throws -> GIDSignInResult {
        switch signInResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        case .none:
            XCTFail("signInResult not set")
            throw AuthError.failedToSignIn(provider: .google)
        }
    }
    
    func credential(withIDToken idToken: String, accessToken: String) -> FirebaseAuth.AuthCredential {
        GoogleAuthProvider.credential(withIDToken: "test-id-token", accessToken: "test-access-token")
    }
}
