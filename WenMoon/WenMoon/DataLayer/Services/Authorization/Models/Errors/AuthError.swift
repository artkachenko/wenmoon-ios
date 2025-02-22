//
//  AuthError.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 21.02.25.
//

import Foundation

enum AuthError: DescriptiveError, Equatable {
    case failedToFetchFirebaseToken
    case failedToSignOut
    
    var errorDescription: String {
        switch self {
        case .failedToFetchFirebaseToken:
            return "Failed to fetch Firebase token"
        case .failedToSignOut:
            return "Failed to sign out. Try again later."
        }
    }
}
