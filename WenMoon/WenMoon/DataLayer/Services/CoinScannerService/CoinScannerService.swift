//
//  CoinScannerService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation
import Combine

protocol CoinScannerService {
    func getCoins(at page: Int) -> AnyPublisher<[Coin], APIError>
    func searchCoins(by query: String) -> AnyPublisher<CoinSearchResult, APIError>
    func getMarketData(for coinIDs: [String]) -> AnyPublisher<[String: CoinMarketData], APIError>
}

final class CoinScannerServiceImpl: BaseBackendService, CoinScannerService {

    // MARK: - Initializers

    convenience init() {
        let baseURL = URL(string: "https://api.coingecko.com/api/v3/")!
        self.init(baseURL: baseURL)
    }

    // MARK: - CoinScannerService

    func getCoins(at page: Int) -> AnyPublisher<[Coin], APIError> {
        let path = "coins/markets"
        // TODO: - Replace the hardcoded parameters with the actual app settings
        return httpClient.get(path: path, parameters: ["vs_currency": "usd",
                                                       "order": "market_cap_desc",
                                                       "per_page": "100",
                                                       "page": String(page),
                                                       "sparkline": "false",
                                                       "locale": "en"])
        .decode(type: [Coin].self, decoder: decoder)
        .mapError { [weak self] error in
            self?.mapToAPIError(error) ?? APIError.unknown(response: URLResponse())
        }
        .eraseToAnyPublisher()
    }

    func searchCoins(by query: String) -> AnyPublisher<CoinSearchResult, APIError> {
        let path = "search"
        return httpClient.get(path: path, parameters: ["query": query])
            .decode(type: CoinSearchResult.self, decoder: decoder)
            .mapError { [weak self] error in
                self?.mapToAPIError(error) ?? APIError.unknown(response: URLResponse())
            }
            .eraseToAnyPublisher()
    }

    func getMarketData(for coinIDs: [String]) -> AnyPublisher<[String: CoinMarketData], APIError> {
        let path = "simple/price"
        // TODO: - Replace the hardcoded parameters with the actual app settings
        return httpClient.get(path: path, parameters: ["ids": coinIDs.joined(separator: ","),
                                                       "vs_currencies": "usd",
                                                       "include_24hr_change": "true"])
        .decode(type: [String: CoinMarketData].self, decoder: decoder)
        .mapError { [weak self] error in
            self?.mapToAPIError(error) ?? APIError.unknown(response: URLResponse())
        }
        .eraseToAnyPublisher()
    }

    private func mapToAPIError(_ error: Error) -> APIError {
        guard let error = error as? APIError else {
            return .apiError(error: error as? URLError ?? .init(.unknown),
                             description: error.localizedDescription)
        }
        return error
    }
}
