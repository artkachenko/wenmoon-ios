//
//  AuthStateManager.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 21.02.25.
//

import Foundation

// MARK: - AuthState
enum AuthState: Equatable {
    case authenticated(_ account: Account? = nil)
    case unauthenticated
}

// MARK: - AuthStateManager
protocol AuthStateManager {
    var authState: AuthState { get }
    
    func fetchAccount(authToken: String?) async throws
    func signOut() throws
}

// MARK: - AuthStateManagerImpl
final class AuthStateManagerImpl: AuthStateManager {
    // MARK: - Properties
    private let firebaseAuthService: FirebaseAuthService
    private let accountService: AccountService
    
    private(set) var authState: AuthState = .unauthenticated
    
    // MARK: - Initializers
    convenience init() {
        self.init(firebaseAuthService: FirebaseAuthServiceImpl(), accountService: AccountServiceImpl())
    }
    
    init(firebaseAuthService: FirebaseAuthService, accountService: AccountService) {
        self.firebaseAuthService = firebaseAuthService
        self.accountService = accountService
    }
    
    // MARK: - Internal Methods
    func fetchAccount(authToken: String?) async throws {
        guard firebaseAuthService.userID != nil else { return }
        
        let token: String
        if let authToken {
            token = authToken
        } else {
            token = try await fetchAuthToken()
        }
        
        let account = try await accountService.getAccount(authToken: token)
        authState = .authenticated(account)
    }
    
    func signOut() throws {
        do {
            try firebaseAuthService.signOut()
            authState = .unauthenticated
        } catch {
            throw AuthError.failedToSignOut
        }
    }
    
    // MARK: - Private Methods
    private func fetchAuthToken() async throws -> String {
        guard let token = try await firebaseAuthService.getIDToken() else {
            throw AuthError.failedToFetchFirebaseToken
        }
        return token
    }
}
