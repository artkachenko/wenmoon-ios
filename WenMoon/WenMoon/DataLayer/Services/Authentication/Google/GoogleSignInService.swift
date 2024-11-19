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
    func signIn(withPresenting viewController: UIViewController, completion: @escaping (GIDSignInResult?, Error?) -> Void)
    func credential(withIDToken idToken: String, accessToken: String) -> AuthCredential
}

final class GoogleSignInServiceImpl: GoogleSignInService {
    // MARK: - GoogleSignInService
    func configure(clientID: String) {
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
    }
    
    func signIn(withPresenting viewController: UIViewController, completion: @escaping (GIDSignInResult?, Error?) -> Void) {
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController, completion: completion)
    }
    
    func credential(withIDToken idToken: String, accessToken: String) -> AuthCredential {
        GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
    }
}
