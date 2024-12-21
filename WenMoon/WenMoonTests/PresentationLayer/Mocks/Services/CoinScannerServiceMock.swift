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
    var getCoinsByIDsResult: Result<[Coin], APIError>!
    var searchCoinsByQueryResult: Result<[Coin], APIError>!
    var getMarketDataResult: Result<[String: MarketData], APIError>!
    var getChartDataResult: Result<[String: [ChartData]], APIError>!
    var getGlobalCryptoMarketDataResult: Result<GlobalCryptoMarketData, APIError>!
    var getGlobalMarketDataResult: Result<GlobalMarketData, APIError>!
    
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
    
    func getCoins(by ids: [String]) async throws -> [Coin] {
        switch getCoinsByIDsResult {
        case .success(let coins):
            return coins
        case .failure(let error):
            throw error
        case .none:
            XCTFail("getCoinsByIDsResult not set")
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
        switch getMarketDataResult {
        case .success(let marketData):
            return marketData
        case .failure(let error):
            throw error
        case .none:
            XCTFail("getMarketDataResult not set")
            throw APIError.unknown(response: URLResponse())
        }
    }
    
    func getChartData(for symbol: String, timeframe: String, currency: String) async throws -> [String: [ChartData]] {
        switch getChartDataResult {
        case .success(let chartData):
            return chartData
        case .failure(let error):
            throw error
        case .none:
            XCTFail("getChartDataResult not set")
            throw APIError.unknown(response: URLResponse())
        }
    }
    
    func getGlobalCryptoMarketData() async throws -> GlobalCryptoMarketData {
        switch getGlobalCryptoMarketDataResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        case .none:
            XCTFail("getGlobalCryptoMarketDataResult not set")
            throw APIError.unknown(response: URLResponse())
        }
    }
    
    func getGlobalMarketData() async throws -> GlobalMarketData {
        switch getGlobalMarketDataResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        case .none:
            XCTFail("getGlobalMarketDataResult not set")
            throw APIError.unknown(response: URLResponse())
        }
    }
}
