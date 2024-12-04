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
    
    func signIn(withPresenting viewController: UIViewController, completion: @escaping (GIDSignInResult?, Error?) -> Void) {
        switch signInResult {
        case .success(let signInResult):
            completion(signInResult, nil)
        case .failure(let error):
            completion(nil, error)
        case .none:
            XCTFail("signInResult not set")
            completion(nil, NSError(domain: "GoogleSignInMock", code: -1, userInfo: [NSLocalizedDescriptionKey: "signInResult not set"]))
        }
    }
    
    func credential(withIDToken idToken: String, accessToken: String) -> FirebaseAuth.AuthCredential {
        GoogleAuthProvider.credential(withIDToken: "someIDToken", accessToken: "someAccessToken")
    }
}
