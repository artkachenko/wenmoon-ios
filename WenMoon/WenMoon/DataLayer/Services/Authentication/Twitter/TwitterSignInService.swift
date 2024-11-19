//
//  TwitterSignInService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 25.11.24.
//

import FirebaseAuth

protocol TwitterSignInService {
    func signIn(completion: @escaping (AuthCredential?, Error?) -> Void)
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
    func signIn(completion: @escaping (AuthCredential?, Error?) -> Void) {
        twitterProvider.getCredentialWith(nil) { credential, error in
            completion(credential, error)
        }
    }
}
