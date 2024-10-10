//
//  CoinScannerService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

protocol CoinScannerService {
    func getCoins(at page: Int) async throws -> [Coin]
    func searchCoins(by query: String) async throws -> CoinSearchResult
    func getMarketData(for coinIDs: [String]) async throws -> [String: MarketData]
}

final class CoinScannerServiceImpl: BaseBackendService, CoinScannerService {

    // MARK: - Initializers

    convenience init() {
        let baseURL = URL(string: "https://api.coingecko.com/api/v3/")!
        self.init(baseURL: baseURL)
    }

    // MARK: - CoinScannerService

    func getCoins(at page: Int) async throws -> [Coin] {
        let path = "coins/markets"
        // TODO: - Replace the hardcoded parameters with the actual app settings
        let data = try await httpClient.get(path: path, parameters: ["vs_currency": "usd",
                                                                     "order": "market_cap_desc",
                                                                     "per_page": "250",
                                                                     "page": String(page),
                                                                     "sparkline": "false",
                                                                     "locale": "en"])
        do {
            return try decoder.decode([Coin].self, from: data)
        } catch {
            throw mapToAPIError(error)
        }
    }

    func searchCoins(by query: String) async throws -> CoinSearchResult {
        let path = "search"
        let data = try await httpClient.get(path: path, parameters: ["query": query])
        do {
            return try decoder.decode(CoinSearchResult.self, from: data)
        } catch {
            throw mapToAPIError(error)
        }
    }

    func getMarketData(for coinIDs: [String]) async throws -> [String: MarketData] {
        let path = "simple/price"
        // TODO: - Replace the hardcoded parameters with the actual app settings
        let data = try await httpClient.get(path: path, parameters: ["ids": coinIDs.joined(separator: ","),
                                                                     "vs_currencies": "usd",
                                                                     "include_24hr_change": "true"])
        do {
            return try decoder.decode([String: MarketData].self, from: data)
        } catch {
            throw mapToAPIError(error)
        }
    }
}
