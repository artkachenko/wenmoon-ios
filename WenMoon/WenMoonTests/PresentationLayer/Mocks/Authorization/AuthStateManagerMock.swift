//
//  AuthStateManagerMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.02.25.
//

import XCTest
@testable import WenMoon

class AuthStateManagerMock: AuthStateManager {
    var authState: AuthState = .unauthenticated
    
    var fetchAccountResult: Result<Account, AuthError>!
    var signOutResult: Result<Void, AuthError>!
    
    func fetchAccount(authToken: String?) async throws {
        switch fetchAccountResult {
        case .success(let account):
            authState = .authenticated(account)
        case .failure(let error):
            throw error
        case .none:
            XCTFail("fetchAccountResult not set")
        }
    }
    
    func signOut() throws {
        switch signOutResult {
        case .success:
            authState = .unauthenticated
        case .failure(let error):
            throw error
        case .none:
            XCTFail("signOutResult not set")
        }
    }
}
