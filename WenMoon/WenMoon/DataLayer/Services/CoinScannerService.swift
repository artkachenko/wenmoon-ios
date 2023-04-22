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
}

final class CoinScannerServiceImpl: BaseBackendService, CoinScannerService {

    func getCoins(at page: Int) -> AnyPublisher<[Coin], APIError> {
        let path = "coins/markets"
        return httpClient.get(path: path, parameters: ["vs_currency": "USD",
                                                       "order": "market_cap_desc",
                                                       "per_page": "100",
                                                       "page": String(page),
                                                       "sparkline": "false",
                                                       "locale": "en"])
            .decode(type: [Coin].self, decoder: decoder)
            .mapError { error in
                guard let error = error as? APIError else {
                    return .apiError(error: error as? URLError ?? .init(.unknown),
                                     description: error.localizedDescription)
                }
                return error
            }
            .eraseToAnyPublisher()
    }

    func searchCoins(by query: String) -> AnyPublisher<CoinSearchResult, APIError> {
        let path = "search"
        return httpClient.get(path: path, parameters: ["query": query])
            .decode(type: CoinSearchResult.self, decoder: decoder)
            .mapError { error in
                guard let error = error as? APIError else {
                    return .apiError(error: error as? URLError ?? .init(.unknown),
                                     description: error.localizedDescription)
                }
                return error
            }
            .eraseToAnyPublisher()
    }
}
