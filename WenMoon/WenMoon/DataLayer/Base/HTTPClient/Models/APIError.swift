//
//  APIError.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

enum APIError: DescriptiveError, Equatable {
    case apiError(description: String)
    case invalidEndpoint(endpoint: String)
    case noNetworkConnection
    case failedToEncodeBody
    case failedToDecodeResponse
    case unknown(response: URLResponse)
    
    var errorDescription: String {
        switch self {
        case let .apiError(description):
            return description
        case let .invalidEndpoint(endpoint):
            return "Invalid endpoint: \(endpoint)"
        case .noNetworkConnection:
            return "No internet connection"
        case .failedToEncodeBody:
            return "Failed to encode request body"
        case .failedToDecodeResponse:
            return "Failed to decode response"
        case let .unknown(response):
            return "Unknown error occured. Reason: \(response.description)"
        }
    }
}
