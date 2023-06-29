//
//  APIError.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

enum APIError: LocalizedError, Equatable {
    case apiError(description: String)
    case invalidEndpoint(endpoint: String)
    case failedToEncodeBody
    case noNetworkConnection
    case unknown(response: URLResponse)

    public var errorDescription: String? {
        switch self {
        case let .apiError(description):
            return description
        case let .invalidEndpoint(endpoint):
            return "Invalid endpoint: \(endpoint)"
        case .failedToEncodeBody:
            return "Failed to encode request body."
        case .noNetworkConnection:
            return "No internet connection."
        case let .unknown(response):
            return "Unknown error occured. Reason: \(response.description)"
        }
    }
}
