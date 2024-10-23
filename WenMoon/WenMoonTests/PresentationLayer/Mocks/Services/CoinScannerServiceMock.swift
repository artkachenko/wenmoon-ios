//
//  CoinScannerServiceMock.swift
//  WenMoonTests
//
//  Created by Artur Tkachenko on 22.04.23.
//

import XCTest
@testable import WenMoon

class CoinScannerServiceMock: CoinScannerService {
    // MARK: - Properties
    var getCoinsAtPageResult: Result<[Coin], APIError>!
    var searchCoinsByQueryResult: Result<[Coin], APIError>!
    var getMarketDataForCoinsResult: Result<[String: MarketData], APIError>!
    
    // MARK: - CoinScannerService
    func getCoins(at page: Int) async throws -> [Coin] {
        switch getCoinsAtPageResult {
        case .success(let coins):
            return coins
        case .failure(let error):
            throw error
        case .none:
            XCTFail("getCoinsAtPageResult not set")
            throw APIError.unknown(response: URLResponse())
        }
    }
    
    func searchCoins(by query: String) async throws -> [Coin] {
        switch searchCoinsByQueryResult {
        case .success(let searchedCoins):
            return searchedCoins
        case .failure(let error):
            throw error
        case .none:
            XCTFail("searchCoinsByQueryResult not set")
            throw APIError.unknown(response: URLResponse())
        }
    }
    
    func getMarketData(for coinIDs: [String]) async throws -> [String: MarketData] {
        switch getMarketDataForCoinsResult {
        case .success(let marketData):
            return marketData
        case .failure(let error):
            throw error
        case .none:
            XCTFail("getMarketDataForCoinIDsResult not set")
            throw APIError.unknown(response: URLResponse())
        }
    }
}
