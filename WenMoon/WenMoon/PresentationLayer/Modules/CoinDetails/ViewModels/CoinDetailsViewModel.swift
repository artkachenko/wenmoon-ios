//
//  CoinDetailsViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 07.11.24.
//

import Foundation

final class CoinDetailsViewModel: BaseViewModel {
    // MARK: - Properties
    @Published var coin: CoinData
    @Published private(set) var chartData: ChartData?
    
    var chartDataCache: [ChartTimeframe: ChartData] = [:]
    
    private let chartDataService: ChartDataService
    
    // MARK: - Initializers
    convenience init(coin: CoinData) {
        self.init(coin: coin, chartDataService: ChartDataServiceImpl())
    }
    
    init(coin: CoinData, chartDataService: ChartDataService) {
        self.coin = coin
        self.chartDataService = chartDataService
    }
    
    @MainActor
    func fetchChartData(on timeframe: ChartTimeframe = .oneDay) async {
        isLoading = true
        defer { isLoading = false }
        
        if let cachedData = chartDataCache[timeframe] {
            chartData = cachedData
            return
        }
        
        do {
            let fetchedData = try await chartDataService.getChartData(for: coin.id, timeframe: timeframe)
            chartDataCache[timeframe] = fetchedData
            chartData = fetchedData
        } catch {
            setErrorMessage(error)
        }
    }
}

enum ChartTimeframe: String, CaseIterable {
    case oneDay = "1"
    case oneWeek = "7"
    case oneMonth = "31"
    case oneYear = "365"
    
    var title: String {
        switch self {
        case .oneDay: return "1D"
        case .oneWeek: return "1W"
        case .oneMonth: return "1M"
        case .oneYear: return "1Y"
        }
    }
}
