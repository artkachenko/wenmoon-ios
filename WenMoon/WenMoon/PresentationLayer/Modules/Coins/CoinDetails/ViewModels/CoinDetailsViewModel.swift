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
    @Published private(set) var chartData: [ChartData] = []
    
    var chartDataCache: [String: [ChartData]] = [:]
    
    private let coinScannerService: CoinScannerService
    
    // MARK: - Initializers
    convenience init(coin: CoinData, chartData: [String: [ChartData]]) {
        self.init(
            coin: coin,
            chartData: chartData,
            coinScannerService: CoinScannerServiceImpl()
        )
    }
    
    init(
        coin: CoinData,
        chartData: [String: [ChartData]],
        coinScannerService: CoinScannerService
    ) {
        self.coin = coin
        self.coinScannerService = coinScannerService
        if !chartData.isEmpty {
            self.chartDataCache = chartData
            self.chartData = chartData[Timeframe.oneHour.rawValue] ?? []
        }
        super.init()
    }
    
    // MARK: - Internal Methods
    @MainActor
    func fetchChartData(on timeframe: Timeframe = .oneHour) async {
        isLoading = true
        defer { isLoading = false }
        
        if let cachedData = chartDataCache[timeframe.rawValue] {
            chartData = cachedData
            return
        }
        
        do {
            let fetchedData = try await coinScannerService.getChartData(for: coin.symbol, currency: .usd)
            for timeframe in Timeframe.allCases {
                if let data = fetchedData[timeframe.rawValue] {
                    chartDataCache[timeframe.rawValue] = data
                }
            }
            chartData = chartDataCache[timeframe.rawValue] ?? []
        } catch {
            setErrorMessage(error)
        }
    }
}
