//
//  CoinScannerService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

protocol CoinScannerService {
    func getCoins(at page: Int) async throws -> [Coin]
    func getCoinDetails(for id: String) async throws -> CoinDetails
    func getChartData(for id: String, on timeframe: String, currency: String) async throws -> [ChartData]
    func searchCoins(by query: String) async throws -> [Coin]
    func getMarketData(for ids: [String]) async throws -> [String: MarketData]
    func getFearAndGreedIndex() async throws -> FearAndGreedIndex
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
    
    func getCoinDetails(for id: String) async throws -> CoinDetails {
        do {
            let data = try await httpClient.get(path: "coin-details", parameters: ["id": id])
            return try decoder.decode(CoinDetails.self, from: data)
        } catch {
            throw mapToAPIError(error)
        }
    }
    
    func getChartData(for id: String, on timeframe: String, currency: String) async throws -> [ChartData] {
        let parameters = ["id": id, "timeframe": timeframe, "currency": currency]
        do {
            let data = try await httpClient.get(path: "chart-data", parameters: parameters)
            return try decoder.decode([ChartData].self, from: data)
        } catch {
            throw mapToAPIError(error)
        }
    }
    
    func searchCoins(by query: String) async throws -> [Coin] {
        do {
            let data = try await httpClient.get(path: "search", parameters: ["query": query])
            let searchedCoins = try decoder.decode([Coin].self, from: data)
            return searchedCoins
        } catch {
            throw mapToAPIError(error)
        }
    }
    
    func getMarketData(for ids: [String]) async throws -> [String: MarketData] {
        do {
            let data = try await httpClient.get(
                path: "market-data",
                parameters: ["ids": ids.joined(separator: ",")]
            )
            let marketData = try decoder.decode([String: MarketData].self, from: data)
            return marketData
        } catch {
            throw mapToAPIError(error)
        }
    }
    
    func getFearAndGreedIndex() async throws -> FearAndGreedIndex {
        do {
            let data = try await httpClient.get(path: "fear-and-greed")
            return try decoder.decode(FearAndGreedIndex.self, from: data)
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
