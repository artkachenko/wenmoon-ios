//
//  CoinScannerService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

protocol CoinScannerService {
    func getCoins(at page: Int) async throws -> [Coin]
    func getCoins(by ids: [String]) async throws -> [Coin]
    func searchCoins(by query: String) async throws -> [Coin]
    func getMarketData(for coinIDs: [String]) async throws -> [String: MarketData]
    func getChartData(for symbol: String, timeframe: String, currency: String) async throws -> [String: [ChartData]]
    func getGlobalCryptoMarketData() async throws -> GlobalCryptoMarketData
    func getGlobalMarketData() async throws -> GlobalMarketData
}

final class CoinScannerServiceImpl: BaseBackendService, CoinScannerService {
    // MARK: - CoinScannerService
    func getCoins(at page: Int) async throws -> [Coin] {
        let parameters = ["page": String(page)]
        do {
            let data = try await httpClient.get(path: "coins", parameters: parameters)
            return try decoder.decode([Coin].self, from: data)
        } catch {
            throw mapToAPIError(error)
        }
    }
    
    func getCoins(by ids: [String]) async throws -> [Coin] {
        let parameters = ["ids": ids.joined(separator: ",")]
        do {
            let data = try await httpClient.get(path: "coins", parameters: parameters)
            return try decoder.decode([Coin].self, from: data)
        } catch {
            throw mapToAPIError(error)
        }
    }
    
    func searchCoins(by query: String) async throws -> [Coin] {
        do {
            let data = try await httpClient.get(path: "search", parameters: ["query": query])
            let searchedCoins = try decoder.decode([Coin].self, from: data)
            print("Searched coins: \(searchedCoins)")
            return searchedCoins
        } catch {
            throw mapToAPIError(error)
        }
    }
    
    func getMarketData(for coinIDs: [String]) async throws -> [String: MarketData] {
        do {
            let data = try await httpClient.get(
                path: "market-data",
                parameters: ["ids": coinIDs.joined(separator: ",")]
            )
            let marketData = try decoder.decode([String: MarketData].self, from: data)
            print("Market Data: \(marketData)")
            return marketData
        } catch {
            throw mapToAPIError(error)
        }
    }
    
    func getChartData(for symbol: String, timeframe: String, currency: String) async throws -> [String: [ChartData]] {
        let parameters = ["symbol": symbol, "timeframe": timeframe, "currency": currency]
        do {
            let data = try await httpClient.get(path: "ohlc", parameters: parameters)
            return try decoder.decode([String: [ChartData]].self, from: data)
        } catch {
            throw mapToAPIError(error)
        }
    }
    
    func getGlobalCryptoMarketData() async throws -> GlobalCryptoMarketData {
        do {
            let data = try await httpClient.get(path: "global-crypto-market-data")
            return try decoder.decode(GlobalCryptoMarketData.self, from: data)
        } catch {
            throw mapToAPIError(error)
        }
    }
    
    func getGlobalMarketData() async throws -> GlobalMarketData {
        do {
            let data = try await httpClient.get(path: "global-market-data")
            return try decoder.decode(GlobalMarketData.self, from: data)
        } catch {
            throw mapToAPIError(error)
        }
    }
}
