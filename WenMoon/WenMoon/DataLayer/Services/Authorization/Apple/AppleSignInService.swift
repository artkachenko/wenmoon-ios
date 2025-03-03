//
//  AppleSignInService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 03.03.25.
//

import FirebaseAuth
import AuthenticationServices
import CryptoKit

protocol AppleSignInService {
    func singIn() async throws -> AuthCredential
}

final class AppleSignInServiceImpl: NSObject, AppleSignInService {
    private var currentNonce: String?
    private var continuation: CheckedContinuation<AuthCredential, Error>?
    
    // MARK: - AppleSignInService
    func singIn() async throws -> AuthCredential {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            let nonce = randomNonceString()
            self.currentNonce = nonce
            
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            request.nonce = sha256(nonce)
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }
    
    // MARK: - Helpers
    private func randomNonceString(length: Int = 32) -> String {
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
        }
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        return String(randomBytes.map { charset[Int($0) % charset.count] })
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInServiceImpl: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce,
                  let appleIDToken = appleIDCredential.identityToken,
                  let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                continuation?.resume(throwing: AuthError.failedToSignIn(provider: .apple))
                return
            }
            let credential = OAuthProvider.appleCredential(
                withIDToken: idTokenString,
                rawNonce: nonce,
                fullName: appleIDCredential.fullName
            )
            continuation?.resume(returning: credential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding
extension AppleSignInServiceImpl: ASAuthorizationControllerPresentationContextProviding {
    @objc func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let connectedScenes = UIApplication.shared.connectedScenes
        guard let windowScene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            fatalError("Unable to find a suitable presentation window.")
        }
        return window
    }
}
