//
//  FirebaseAuthServiceMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 02.12.24.
//

import XCTest
import FirebaseAuth
@testable import WenMoon

class FirebaseAuthServiceMock: FirebaseAuthService {
    // MARK: - Properties
    var clientID: String? { "test-client-id" }
    var userID: String? { "test-user-id" }
    
    var signInResult: Result<AuthDataResult, Error>!
    var signOutResult: Result<Void, Error>!
    var idTokenResult: Result<String, Error>!
    
    // MARK: - FirebaseAuthService
    func signIn(with credential: AuthCredential) async throws -> AuthDataResult {
        switch signInResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        case .none:
            XCTFail("signInResult not set")
            throw AuthError.failedToSignIn()
        }
    }
    
    func signOut() throws {
        switch signOutResult {
        case .success:
            return
        case .failure(let error):
            throw error
        case .none:
            XCTFail("signOutResult not set")
        }
    }
    
    func getIDToken() async throws -> String {
        switch idTokenResult {
        case .success(let result):
            return result
        case .failure(let error):
            throw error
        case .none:
            XCTFail("idTokenResult not set")
            throw AuthError.failedToFetchFirebaseToken
        }
    }
}
