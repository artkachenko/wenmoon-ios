//
//  GoogleSignInService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 25.11.24.
//

import FirebaseAuth
import GoogleSignIn

protocol GoogleSignInService {
    func configure(clientID: String)
    func signIn(withPresenting viewController: UIViewController) async throws -> GIDSignInResult
    func credential(withIDToken idToken: String, accessToken: String) -> AuthCredential
}

final class GoogleSignInServiceImpl: GoogleSignInService {
    // MARK: - GoogleSignInService
    func configure(clientID: String) {
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    @MainActor
    func signIn(withPresenting viewController: UIViewController) async throws -> GIDSignInResult {
        try await withCheckedThrowingContinuation { continuation in
            GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
                guard (error == nil) else {
                    continuation.resume(throwing: error!)
                    return
                }
                guard let result else {
                    continuation.resume(throwing: AuthError.failedToSignIn(provider: .google))
                    return
                }
                continuation.resume(returning: result)
            }
        }
    }
    
    func credential(withIDToken idToken: String, accessToken: String) -> AuthCredential {
        GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
    }
}
