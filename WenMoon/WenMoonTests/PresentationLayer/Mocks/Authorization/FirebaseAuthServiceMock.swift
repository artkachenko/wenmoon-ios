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
    var clientID: String? { "someClientID" }
    var userID: String? { "example.email@gmail.com" }
    
    var signInResult: Result<AuthDataResult, Error>!
    var signOutResult: Result<Void, Error>!
    
    // MARK: - FirebaseAuthService
    func signIn(with credential: AuthCredential, completion: @escaping (AuthDataResult?, Error?) -> Void) {
        switch signInResult {
        case .success(let authDataResult):
            completion(authDataResult, nil)
        case .failure(let error):
            completion(nil, error)
        case .none:
            XCTFail("signInResult not set")
            completion(nil, NSError(domain: "FirebaseAuthMock", code: -1, userInfo: [NSLocalizedDescriptionKey: "signInResult not set"]))
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
            throw NSError(domain: "FirebaseAuthMock", code: -2, userInfo: [NSLocalizedDescriptionKey: "signOutResult not set"])
        }
    }
}
