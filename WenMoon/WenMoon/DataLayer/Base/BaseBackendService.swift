//
//  BaseBackendService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

class BaseBackendService {
    // MARK: - Properties
    private(set) var httpClient: HTTPClient
    
    var encoder: JSONEncoder {
        httpClient.encoder.keyEncodingStrategy = .convertToSnakeCase
        return httpClient.encoder
    }
    
    var decoder: JSONDecoder {
        httpClient.decoder.keyDecodingStrategy = .convertFromSnakeCase
        return httpClient.decoder
    }

    // MARK: - Initializers
    convenience init() {
        self.init(httpClient: HTTPClientImpl())
    }
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    // MARK: - Internal Methods
    func mapToAPIError(_ error: Error) -> APIError {
        if let apiError = error as? APIError {
            return apiError
        }
        
        switch error {
        case let nsError as NSError where nsError.domain == NSURLErrorDomain:
            return .noNetworkConnection
        case is EncodingError:
            return .failedToEncodeBody
        case is DecodingError:
            return .failedToDecodeResponse
        default:
            return .apiError(description: error.localizedDescription)
        }
    }
}
