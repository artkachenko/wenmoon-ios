//
//  APIError.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

enum APIError: LocalizedError, Equatable {
    case apiError(error: URLError?, description: String)
    case invalidEndpoint(endpoint: String)
    case noNetworkConnection
    case unknown(response: URLResponse)

    var errorDescription: String? {
        switch self {
        case let .apiError(_, description):
            return description
        case let .invalidEndpoint(endpoint):
            return "Invalid endpoint: \(endpoint)"
        case .noNetworkConnection:
            return "No internet connection"
        case let .unknown(response):
            return "Unknown error. Reason: \(response.description)"
        }
    }
}
