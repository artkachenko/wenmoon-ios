//
//  UserDefaultsError.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 23.05.23.
//

import Foundation

enum UserDefaultsError: DescriptiveError {
    case failedToEncodeObject
    case failedToDecodeObject

    var errorDescription: String {
        switch self {
        case .failedToEncodeObject:
            return "Failed to encode object."
        case .failedToDecodeObject:
            return "Failed to decode object."
        }
    }
}
