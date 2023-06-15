//
//  BaseBackendService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation
import Combine

class BaseBackendService {

    private let baseURL: URL
    private(set) var httpClient: HTTPClient

    private var cancellables = Set<AnyCancellable>()

    var encoder: JSONEncoder {
        httpClient.encoder.keyEncodingStrategy = .convertToSnakeCase
        return httpClient.encoder
    }

    var decoder: JSONDecoder {
        httpClient.decoder.keyDecodingStrategy = .convertFromSnakeCase
        return httpClient.decoder
    }

    convenience init(baseURL: URL) {
        let httpClient = HTTPClientImpl(baseURL: baseURL)
        self.init(httpClient: httpClient, baseURL: baseURL)
    }

    init(httpClient: HTTPClient, baseURL: URL) {
        self.httpClient = httpClient
        self.baseURL = baseURL
    }

    func mapToAPIError(_ error: Error) -> APIError {
        guard let error = error as? APIError else {
            return .apiError(error: error as? URLError ?? .init(.unknown),
                             description: error.localizedDescription)
        }
        return error
    }
}
