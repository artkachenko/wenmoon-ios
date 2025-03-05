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
    var getCoinDetailsResult: Result<CoinDetails, APIError>!
    var getChartDataResult: Result<[ChartData], APIError>!
    var searchCoinsByQueryResult: Result<[Coin], APIError>!
    var getMarketDataResult: Result<[String: MarketData], APIError>!
    var getFearAndGreedIndexResult: Result<FearAndGreedIndex, APIError>!
    var getCryptoGlobalMarketDataResult: Result<CryptoGlobalMarketData, APIError>!
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
    
    func getCoinDetails(for id: String) async throws -> CoinDetails {
        switch getCoinDetailsResult {
        case .success(let coinDetails):
            return coinDetails
        case .failure(let error):
            throw error
        case .none:
            XCTFail("getCoinDetailsResult not set")
            throw APIError.unknown(response: URLResponse())
        }
    }
    
    func getChartData(for id: String, on timeframe: String, currency: String) async throws -> [ChartData] {
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
    
    func getMarketData(for ids: [String]) async throws -> [String: MarketData] {
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
    
    func getFearAndGreedIndex() async throws -> FearAndGreedIndex {
        switch getFearAndGreedIndexResult {
        case .success(let index):
            return index
        case .failure(let error):
            throw error
        case .none:
            XCTFail("getFearAndGreedIndexResult not set")
            throw APIError.unknown(response: URLResponse())
        }
    }
    
    func getCryptoGlobalMarketData() async throws -> CryptoGlobalMarketData {
        switch getCryptoGlobalMarketDataResult {
        case .success(let data):
            return data
        case .failure(let error):
            throw error
        case .none:
            XCTFail("getCryptoGlobalMarketDataResult not set")
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
