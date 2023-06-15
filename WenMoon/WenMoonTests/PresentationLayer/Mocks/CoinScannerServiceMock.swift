//
//  CoinScannerServiceMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.04.23.
//

import XCTest
import Combine
@testable import WenMoon

class CoinScannerServiceMock: CoinScannerService {

    var getCoinsAtPageResult: Result<[Coin], APIError>!
    var searchCoinsByQueryResult: Result<CoinSearchResult, APIError>!
    var getMarketDataForCoinsResult: Result<[String: MarketData], APIError>!

    func getCoins(at page: Int) -> AnyPublisher<[Coin], APIError> {
        Future { [weak self] promise in
            switch self?.getCoinsAtPageResult {
            case .success(let coins):
                promise(.success(coins))
            case .failure(let error):
                promise(.failure(error))
            case .none:
                XCTFail("getCoinsAtPageResult not set")
            }
        }
        .eraseToAnyPublisher()
    }

    func searchCoins(by query: String) -> AnyPublisher<CoinSearchResult, APIError> {
        Future { [weak self] promise in
            switch self?.searchCoinsByQueryResult {
            case .success(let searchedCoins):
                promise(.success(searchedCoins))
            case .failure(let error):
                promise(.failure(error))
            case .none:
                XCTFail("searchCoinsByQueryResult not set")
            }
        }
        .eraseToAnyPublisher()
    }

    func getMarketData(for coinIDs: [String]) -> AnyPublisher<[String: MarketData], APIError> {
        Future { [weak self] promise in
            switch self?.getMarketDataForCoinsResult {
            case .success(let marketData):
                promise(.success(marketData))
            case .failure(let error):
                promise(.failure(error))
            case .none:
                XCTFail("getMarketDataForCoinIDsResult not set")
            }
        }
        .eraseToAnyPublisher()
    }
}
