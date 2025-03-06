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
    var putResponse: Result<Data, APIError>!
    var deleteResponse: Result<Data, APIError>!
    
    var lastRequestedPath: String?
    var lastRequestedParameters: [String: String]?
    
    // MARK: - Initializers
    convenience init() {
        self.init(encoder: JSONEncoder(), decoder: JSONDecoder())
    }
    
    init(encoder: JSONEncoder, decoder: JSONDecoder) {
        self.encoder = encoder
        self.decoder = decoder
    }
    
    // MARK: - HTTPClient
    func get(path: String, parameters: [String: String]?, headers: [String: String]?) async throws -> Data {
        lastRequestedPath = path
        lastRequestedParameters = parameters
        
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
        lastRequestedPath = path
        lastRequestedParameters = parameters
        
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
    
    func put(path: String, parameters: [String: String]?, headers: [String: String]?, body: Data?) async throws -> Data {
        lastRequestedPath = path
        lastRequestedParameters = parameters
        
        guard let result = putResponse else {
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
        lastRequestedPath = path
        lastRequestedParameters = parameters
        
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
