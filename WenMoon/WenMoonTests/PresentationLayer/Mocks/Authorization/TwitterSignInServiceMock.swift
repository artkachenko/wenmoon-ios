//
//  TwitterSignInServiceMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 02.12.24.
//

import XCTest
import FirebaseAuth
@testable import WenMoon

class TwitterSignInServiceMock: TwitterSignInService {
    // MARK: - Properties
    var signInResult: Result<FirebaseAuth.AuthCredential, Error>!
    
    // MARK: - TwitterSignInService
    func signIn(completion: @escaping (FirebaseAuth.AuthCredential?, Error?) -> Void) {
        switch signInResult {
        case .success(let signInResult):
            completion(signInResult, nil)
        case .failure(let error):
            completion(nil, error)
        case .none:
            XCTFail("signInResult not set")
            completion(nil, NSError(domain: "TwitterSignInMock", code: -1, userInfo: [NSLocalizedDescriptionKey: "signInResult not set"]))
        }
    }
}
