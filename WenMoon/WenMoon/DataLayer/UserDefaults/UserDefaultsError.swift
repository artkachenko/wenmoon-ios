//
//  UserDefaultsError.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 23.05.23.
//

import Foundation

enum UserDefaultsError: LocalizedError {
    case failedToEncodeObject(error: Error)
    case failedToDecodeObject(error: Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .failedToEncodeObject(let error):
            return "Failed to encode object: \(error.localizedDescription)"
        case .failedToDecodeObject(let error):
            return "Failed to decode object: \(error.localizedDescription)"
        case .unknown:
            return "Unknown error occured."
        }
    }
}
