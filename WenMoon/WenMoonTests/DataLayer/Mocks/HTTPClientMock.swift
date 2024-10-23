//
//  HTTPClientMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation
@testable import WenMoon

class HTTPClientMock: HTTPClient {
    // MARK: - Properties
    var encoder: JSONEncoder
    var decoder: JSONDecoder
    var getResponse: Result<Data, APIError>!
    var postResponse: Result<Data, APIError>!
    var deleteResponse: Result<Data, APIError>!
    
    // MARK: - Initializers
    convenience init() {
        self.init(encoder: JSONEncoder(), decoder: JSONDecoder())
    }
    
    init(encoder: JSONEncoder, decoder: JSONDecoder) {
        self.encoder = encoder
        self.decoder = decoder
    }
    
    // MARK: - HTTPClient
    func get(path: String, parameters: [String: String]?, headers: [String : String]?) async throws -> Data {
        guard let result = getResponse else {
            throw APIError.unknown(response: URLResponse())
        }
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
    func post(path: String, parameters: [String: String]?, headers: [String: String]?, body: Data?) async throws -> Data {
        guard let result = postResponse else {
            throw APIError.unknown(response: URLResponse())
        }
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
    
    func delete(path: String, parameters: [String: String]?, headers: [String: String]?) async throws -> Data {
        guard let result = deleteResponse else {
            throw APIError.unknown(response: URLResponse())
        }
        switch result {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        }
    }
}
