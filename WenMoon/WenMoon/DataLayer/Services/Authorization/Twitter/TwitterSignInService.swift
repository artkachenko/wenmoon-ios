//
//  TwitterSignInService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 25.11.24.
//

import FirebaseAuth

protocol TwitterSignInService {
    func signIn() async throws -> AuthCredential?
}

final class TwitterSignInServiceImpl: TwitterSignInService {
    // MARK: - Properties
    private let twitterProvider: OAuthProvider
    
    // MARK: - Initializers
    convenience init() {
        self.init(twitterProvider: OAuthProvider(providerID: "twitter.com"))
    }
    
    init(twitterProvider: OAuthProvider) {
        self.twitterProvider = twitterProvider
    }
    
    // MARK: - TwitterSignInService
    func signIn() async throws -> AuthCredential? {
        try await withCheckedThrowingContinuation { continuation in
            twitterProvider.getCredentialWith(nil) { credential, error in
                guard (error == nil) else {
                    continuation.resume(throwing: error!)
                    return
                }
                
                let credential = (credential == nil) ? nil : credential
                continuation.resume(returning: credential)
            }
        }
    }
}
