//
//  ChartDataService.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 08.11.24.
//

import Foundation

protocol ChartDataService {
    func getChartData(for id: String, currency: String, timeframe: ChartTimeframe) async throws -> ChartData
}

extension ChartDataService {
    func getChartData(for id: String, currency: String = "usd", timeframe: ChartTimeframe = .oneDay) async throws -> ChartData {
        try await getChartData(for: id, currency: currency, timeframe: timeframe)
    }
}

final class ChartDataServiceImpl: BaseBackendService, ChartDataService {
    
    convenience init() {
        self.init(baseURLString: "https://api.coingecko.com/api/v3/")
    }
    
    // MARK: - ChartDataService
    func getChartData(for id: String, currency: String = "usd", timeframe: ChartTimeframe) async throws -> ChartData {
        guard isValidTimeframe(timeframe) else {
            throw APIError.invalidParameter(parameter: timeframe.rawValue)
        }
        
        let parameters = ["vs_currency": currency, "days": timeframe.rawValue]
        do {
            let data = try await httpClient.get(path: "coins/\(id)/market_chart", parameters: parameters)
            return try decoder.decode(ChartData.self, from: data)
        } catch {
            throw mapToAPIError(error)
        }
    }
    
    private func isValidTimeframe(_ timeframe: ChartTimeframe) -> Bool {
        [.oneDay, .oneWeek, .oneMonth, .oneYear].contains(timeframe)
    }
}
