//
//  PriceAlertServiceError.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 23.05.23.
//

import Foundation

enum PriceAlertServiceError: LocalizedError {
    case apiError(APIError)
    case deviceTokenNotFound(UserDefaultsError)
    case unknown

    var errorDescription: String? {
        switch self {
        case let .apiError(error):
            return error.errorDescription
        case let .deviceTokenNotFound(error):
            return error.errorDescription
        case .unknown:
            return "Unknown error occured."
        }
    }
}
