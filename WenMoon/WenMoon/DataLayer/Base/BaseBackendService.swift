//
//  BaseBackendService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

class BaseBackendService {

    let httpClient: HTTPClient

    var decoder: JSONDecoder {
        httpClient.decoder.keyDecodingStrategy = .convertFromSnakeCase
        return httpClient.decoder
    }

    convenience init() {
        let httpClient = HTTPClientImpl(baseURL: URL(string: "https://api.coingecko.com/api/v3/")!)
        self.init(httpClient: httpClient)
    }

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
}
