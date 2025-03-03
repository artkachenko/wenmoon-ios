//
//  AuthError.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 21.02.25.
//

import Foundation

enum AuthError: DescriptiveError, Equatable {
    enum AuthProvider {
        case apple
        case google
        case twitter
        
        var name: String {
            switch self {
            case .apple: return "Apple"
            case .google: return "Google"
            case .twitter: return "X"
            }
        }
    }
    
    case failedToFetchAccount
    case failedToDeleteAccount
    case failedToFetchFirebaseToken
    case failedToSignIn(provider: AuthProvider? = nil)
    case failedToSignOut
    case userNotSignedIn
    case unknownError
    
    var errorDescription: String {
        let suffix = " Please try again later."
        switch self {
        case .failedToFetchAccount:
            return "Failed to fetch account." + suffix
        case .failedToDeleteAccount:
            return "Failed to delete account." + suffix
        case .failedToSignIn(let provider):
            guard let provider else {
                return "Failed to sign in." + suffix
            }
            return "Failed to sign in with \(provider.name)." + suffix
        case .failedToSignOut:
            return "Failed to sign out." + suffix
        case .failedToFetchFirebaseToken:
            return "Failed to fetch Firebase token." + suffix
        case .userNotSignedIn:
            return "User is not signed in." + suffix
        case .unknownError:
            return "An unknown error occurred." + suffix
        }
    }
}
