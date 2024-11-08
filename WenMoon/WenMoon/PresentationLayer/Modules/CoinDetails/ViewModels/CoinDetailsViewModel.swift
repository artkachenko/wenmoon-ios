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
    func fetchChartData(on timeframe: ChartTimeframe) async {
        isLoading = true
        defer { isLoading = false }
        do {
            chartData = try await chartDataService.getChartData(for: coin.id, timeframe: timeframe.value)
        } catch {
            setErrorMessage(error)
        }
    }
}

enum ChartTimeframe: String, CaseIterable {
    case oneDay = "1D"
    case oneWeek = "1W"
    case oneMonth = "1M"
    case oneYear = "1Y"
    
    var displayName: String { rawValue }
    
    var value: String {
        switch self {
        case .oneDay: return "1"
        case .oneWeek: return "7"
        case .oneMonth: return "31"
        case .oneYear: return "365"
        }
    }
}
