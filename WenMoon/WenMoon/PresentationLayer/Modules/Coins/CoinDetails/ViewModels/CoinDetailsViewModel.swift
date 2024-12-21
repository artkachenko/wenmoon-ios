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
    convenience init(coin: CoinData) {
        self.init(coin: coin, coinScannerService: CoinScannerServiceImpl())
    }
    
    init(coin: CoinData, coinScannerService: CoinScannerService) {
        self.coin = coin
        self.coinScannerService = coinScannerService
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
            let currency: Currency = .usd
            let fetchedData = try await coinScannerService.getChartData(for: coin.symbol, timeframe: timeframe.rawValue, currency: currency.rawValue)
            chartDataCache = fetchedData
            chartData = chartDataCache[timeframe.rawValue] ?? []
        } catch {
            setErrorMessage(error)
        }
    }
}
