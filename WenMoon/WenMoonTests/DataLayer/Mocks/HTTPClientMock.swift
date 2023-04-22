//
//  HTTPClientMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation
import Combine
@testable import WenMoon

class HTTPClientMock: HTTPClient {

    var decoder: JSONDecoder
    var getResponse: Result<Data, APIError>?

    convenience init() {
        self.init(decoder: .init())
    }

    init(decoder: JSONDecoder) {
        self.decoder = decoder
    }

    func get(path: String, parameters: [String: String]?) -> AnyPublisher<Data, APIError> {
        guard let result = getResponse else {
            return Fail(error: .unknown(response: URLResponse())).eraseToAnyPublisher()
        }
        return result.publisher.eraseToAnyPublisher()
    }
}
