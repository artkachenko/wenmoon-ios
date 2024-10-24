//
//  ErrorFactoryMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 24.10.24.
//

import Foundation
@testable import WenMoon

struct ErrorFactoryMock {
    static func makeAPIError(description: String = "Mocked API error description") -> APIError {
        .apiError(description: description)
    }
    
    static func makeInvalidEndpointError(endpoint: String = "/invalid-endpoint") -> APIError {
        .invalidEndpoint(endpoint: endpoint)
    }
    
    static func makeNoNetworkConnectionError() -> APIError {
        .noNetworkConnection
    }
    
    static func makeFailedToEncodeBodyError() -> APIError {
        .failedToEncodeBody
    }
    
    static func makeFailedToDecodeResponseError() -> APIError {
        .failedToDecodeResponse
    }
    
    static func makeUnknownError(response: URLResponse = URLResponse()) -> APIError {
        .unknown(response: response)
    }
}
