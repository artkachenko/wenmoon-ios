//
//  HTTPClient.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation
import Combine

protocol HTTPClient {
    var encoder: JSONEncoder { get }
    var decoder: JSONDecoder { get }

    func get(path: String,
             parameters: [String: String]?,
             headers: [String: String]?) -> AnyPublisher<Data, APIError>
    func post(path: String,
              parameters: [String: String]?,
              headers: [String: String]?,
              body: Data?) -> AnyPublisher<Data, APIError>
    func delete(path: String,
                parameters: [String: String]?,
                headers: [String: String]?) -> AnyPublisher<Data, APIError>
}

extension HTTPClient {
    func get(path: String,
             parameters: [String: String]? = nil,
             headers: [String: String]? = nil) -> AnyPublisher<Data, APIError> {
        get(path: path, parameters: parameters, headers: headers)
    }

    func post(path: String,
              parameters: [String: String]? = nil,
              headers: [String: String]? = nil,
              body: Data? = nil) -> AnyPublisher<Data, APIError> {
        post(path: path, parameters: parameters, headers: headers, body: body)
    }

    func delete(path: String,
                parameters: [String: String]? = nil,
                headers: [String: String]? = nil) -> AnyPublisher<Data, APIError> {
        delete(path: path, parameters: parameters, headers: headers)
    }
}

final class HTTPClientImpl: HTTPClient {

    // MARK: - Properties

    let baseURL: URL
    let session: URLSession
    let encoder: JSONEncoder
    let decoder: JSONDecoder

    // MARK: - Initializers

    convenience init(baseURL: URL) {
        self.init(baseURL: baseURL,
                  session: .shared,
                  encoder: .init(),
                  decoder: .init())
    }

    init(baseURL: URL, session: URLSession, encoder: JSONEncoder, decoder: JSONDecoder) {
        self.baseURL = baseURL
        self.session = session
        self.encoder = encoder
        self.decoder = decoder
    }

    // MARK: - HTTPClient

    func get(path: String,
             parameters: [String: String]?,
             headers: [String: String]?) -> AnyPublisher<Data, APIError> {
        let httpRequest = HTTPRequest(httpMethod: .get,
                                      path: path,
                                      parameters: parameters,
                                      headers: headers,
                                      body: nil)
        return execute(httpRequest)
    }

    func post(path: String,
              parameters: [String: String]?,
              headers: [String: String]?,
              body: Data?) -> AnyPublisher<Data, APIError> {
        let httpRequest = HTTPRequest(httpMethod: .post,
                                      path: path,
                                      parameters: parameters,
                                      headers: headers,
                                      body: body)
        return execute(httpRequest)
    }

    func delete(path: String,
                parameters: [String: String]?,
                headers: [String: String]?) -> AnyPublisher<Data, APIError> {
        let httpRequest = HTTPRequest(httpMethod: .delete,
                                      path: path,
                                      parameters: parameters,
                                      headers: headers,
                                      body: nil)
        return execute(httpRequest)
    }

    // MARK: - Private

    private func execute(_ httpRequest: HTTPRequest) -> AnyPublisher<Data, APIError> {
        guard var urlComponents = URLComponents(url: absolutePath(httpRequest.path),
                                                resolvingAgainstBaseURL: false) else {
            return Fail(error: .invalidEndpoint(endpoint: httpRequest.path)).eraseToAnyPublisher()
        }
        urlComponents.queryItems = queryitems(from: httpRequest.parameters)

        var urlRequest = URLRequest(url: urlComponents.url!)
        urlRequest.httpMethod = httpRequest.httpMethod.rawValue
        urlRequest.httpBody = httpRequest.body

        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        httpRequest.headers?.forEach { urlRequest.setValue($0.value, forHTTPHeaderField: $0.key) }

        return session.dataTaskPublisher(for: urlRequest)
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse,
                      (200..<300 ~= response.statusCode)
                else {
                    throw APIError.unknown(response: response)
                }
                return data
            }
            .mapError { error in
                guard let error = error as? APIError else {
                    return .apiError(description: error.localizedDescription)
                }
                return error
            }
            .eraseToAnyPublisher()
    }

    private func absolutePath(_ relativePath: String) -> URL {
        guard !relativePath.isEmpty else { return baseURL }
        assert(relativePath.first != "/", "'/' symbol at the begining of url relativePath will cause 'RestrictedIP' error")

        guard let url = URL(string: relativePath, relativeTo: baseURL) else {
            assertionFailure("Failed to construct url for path \(relativePath)")
            return baseURL
        }

        return url.absoluteURL
    }

    private func queryitems(from parameters: [String: String]?) -> [URLQueryItem]? {
        parameters?.compactMap { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
