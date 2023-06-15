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

    var encoder: JSONEncoder
    var decoder: JSONDecoder
    var getResponse: Result<Data, APIError>?
    var postResponse: Result<Data, APIError>?
    var deleteResponse: Result<Data, APIError>?

    convenience init() {
        self.init(encoder: .init(), decoder: .init())
    }

    init(encoder: JSONEncoder, decoder: JSONDecoder) {
        self.encoder = encoder
        self.decoder = decoder
    }

    func get(path: String,
             parameters: [String: String]?,
             headers: [String : String]?) -> AnyPublisher<Data, APIError> {
        guard let result = getResponse else {
            return Fail(error: .unknown(response: URLResponse())).eraseToAnyPublisher()
        }
        return result.publisher.eraseToAnyPublisher()
    }

    func post(path: String,
              parameters: [String: String]?,
              headers: [String: String]?,
              body: Data?) -> AnyPublisher<Data, APIError> {
        guard let result = postResponse else {
            return Fail(error: .unknown(response: URLResponse())).eraseToAnyPublisher()
        }
        return result.publisher.eraseToAnyPublisher()
    }

    func delete(path: String,
                parameters: [String: String]?,
                headers: [String: String]?) -> AnyPublisher<Data, APIError> {
        guard let result = deleteResponse else {
            return Fail(error: .unknown(response: URLResponse())).eraseToAnyPublisher()
        }
        return result.publisher.eraseToAnyPublisher()
    }
}
