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

    // User Defaults
    private(set) var userDefaultsManager: UserDefaultsManager
    private(set) var deviceTokenKey = "DEVICE_TOKEN_KEY"
    private(set) var userDefaultsError: UserDefaultsError?

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
        self.init(httpClient: httpClient, baseURL: baseURL, userDefaultsManager: UserDefaultsManagerImpl())
    }

    init(httpClient: HTTPClient, baseURL: URL, userDefaultsManager: UserDefaultsManager) {
        self.httpClient = httpClient
        self.baseURL = baseURL
        self.userDefaultsManager = userDefaultsManager

        userDefaultsManager.errorPublisher.sink { [weak self] userDefaultsError in
            self?.userDefaultsError = userDefaultsError
        }
        .store(in: &cancellables)
    }
}
