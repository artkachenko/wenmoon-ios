//
//  CoinListViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation
import SwiftData

final class CoinListViewModel: BaseViewModel {
    // MARK: - Properties
    @Published var coins: [CoinData] = []
    @Published var marketData: [String: MarketData] = [:]
    @Published var chartData: [String: [String: [ChartData]]] = [:]
    
    private let coinScannerService: CoinScannerService
    private let priceAlertService: PriceAlertService
    private var cacheTimer: Timer?
    private var chartDataFetchTimer: Timer?
    
    // MARK: - Initializers
    convenience init() {
        self.init(
            coinScannerService: CoinScannerServiceImpl(),
            priceAlertService: PriceAlertServiceImpl(),
            firebaseAuthService: FirebaseAuthServiceImpl()
        )
    }
    
    init(
        coinScannerService: CoinScannerService,
        priceAlertService: PriceAlertService,
        firebaseAuthService: FirebaseAuthService,
        userDefaultsManager: UserDefaultsManager? = nil,
        swiftDataManager: SwiftDataManager? = nil
    ) {
        self.coinScannerService = coinScannerService
        self.priceAlertService = priceAlertService
        super.init(
            firebaseAuthService: firebaseAuthService,
            userDefaultsManager: userDefaultsManager,
            swiftDataManager: swiftDataManager
        )
        startCacheTimer()
    }
    
    deinit {
        cacheTimer?.invalidate()
        chartDataFetchTimer?.invalidate()
    }
    
    // MARK: - Internal Methods
    @MainActor
    func fetchCoins() async {
        if isFirstLaunch {
            await fetchPredefinedCoins()
        } else {
            let descriptor = FetchDescriptor<CoinData>(sortBy: [SortDescriptor(\.marketCapRank)])
            var fetchedCoins = fetch(descriptor)
            if let savedOrder = try? userDefaultsManager.getObject(forKey: "coinOrder", objectType: [String].self) {
                fetchedCoins.sort { coin1, coin2 in
                    let index1 = savedOrder.firstIndex(of: coin1.id) ?? .max
                    let index2 = savedOrder.firstIndex(of: coin2.id) ?? .max
                    return index1 < index2
                }
            }
            coins = fetchedCoins
            await fetchMarketData()
        }
    }
    
    @MainActor
    func fetchMarketData() async {
        let coinIDs = coins.map { $0.id }
        let existingMarketData = coinIDs.compactMap { marketData[$0] }
        
        guard existingMarketData.count != coins.count else { return }
        
        do {
            let fetchedMarketData = try await coinScannerService.getMarketData(for: coinIDs)
            for (index, coinID) in coinIDs.enumerated() {
                if let coinMarketData = fetchedMarketData[coinID] {
                    marketData[coinID] = coinMarketData
                    coins[index].currentPrice = coinMarketData.currentPrice ?? .zero
                    coins[index].marketCap = coinMarketData.marketCap ?? .zero
                    coins[index].marketCapRank = coinMarketData.marketCapRank ?? .zero
                    coins[index].fullyDilutedValuation = coinMarketData.fullyDilutedValuation ?? .zero
                    coins[index].totalVolume = coinMarketData.totalVolume ?? .zero
                    coins[index].high24H = coinMarketData.high24H ?? .zero
                    coins[index].low24H = coinMarketData.low24H ?? .zero
                    coins[index].priceChange24H = coinMarketData.priceChange24H ?? .zero
                    coins[index].priceChangePercentage24H = coinMarketData.priceChangePercentage24H ?? .zero
                    coins[index].marketCapChange24H = coinMarketData.marketCapChange24H ?? .zero
                    coins[index].marketCapChangePercentage24H = coinMarketData.marketCapChangePercentage24H ?? .zero
                    coins[index].circulatingSupply = coinMarketData.circulatingSupply ?? .zero
                    coins[index].totalSupply = coinMarketData.totalSupply ?? .zero
                    coins[index].ath = coinMarketData.ath ?? .zero
                    coins[index].athChangePercentage = coinMarketData.athChangePercentage ?? .zero
                    coins[index].athDate = coinMarketData.athDate ?? ""
                    coins[index].atl = coinMarketData.atl ?? .zero
                    coins[index].atlChangePercentage = coinMarketData.atlChangePercentage ?? .zero
                    coins[index].atlDate = coinMarketData.atlDate ?? ""
                }
            }
            save()
        } catch {
            setErrorMessage(error)
        }
    }
    
    func clearCacheIfNeeded() {
        if !marketData.isEmpty {
            marketData.removeAll()
            print("Market Data cache cleared.")
        }
    }
    
    @MainActor
    func fetchPriceAlerts() async {
        guard let userID, let deviceToken, !coins.isEmpty else {
            print("User ID is nil, or the device token is nil, or the coins array is empty")
            coins = coins.map { coin in
                let updatedCoin = coin
                updatedCoin.priceAlerts = []
                return updatedCoin
            }
            return
        }
        do {
            let priceAlerts = try await priceAlertService.getPriceAlerts(userID: userID, deviceToken: deviceToken)
            for (index, coin) in coins.enumerated() {
                let matchingPriceAlerts = priceAlerts.filter({ $0.id.contains(coin.id) })
                coins[index].priceAlerts = matchingPriceAlerts
            }
        } catch {
            setErrorMessage(error)
        }
    }
    
    @MainActor
    func saveCoin(_ coin: Coin) async {
        guard !coins.contains(where: { $0.id == coin.id }) else { return }
        let imageData = coin.image != nil ? await loadImage(from: coin.image!) : nil
        let newCoin = CoinData(from: coin, imageData: imageData)
        coins.append(newCoin)
        insert(newCoin)
    }
    
    func saveCoinOrder() {
        do {
            let ids = coins.map { $0.id }
            try userDefaultsManager.setObject(ids, forKey: "coinOrder")
        } catch {
            setErrorMessage(error)
        }
    }
    
    @MainActor
    func deleteCoin(_ coinID: String) async {
        guard let coin = coins.first(where: { $0.id == coinID }) else { return }
        if let index = coins.firstIndex(of: coin) {
            coins.remove(at: index)
        }
        delete(coin)
    }
    
    // When the target price has been reached
    func toggleOffPriceAlert(for id: String) {
        for index in coins.indices {
            if let alertIndex = coins[index].priceAlerts.firstIndex(where: { $0.id == id }) {
                coins[index].priceAlerts.remove(at: alertIndex)
                break
            }
        }
    }
    
    @MainActor
    func fetchChartData(for symbol: String) async {
        do {
            chartData[symbol] = try await coinScannerService.getChartData(for: symbol, currency: .usd)
        } catch {
            print("Failed to fetch data for \(symbol): \(error)")
        }
    }
    
    func fetchChartData() async {
        await withTaskGroup(of: Void.self) { group in
            for coin in coins {
                group.addTask { [weak self] in
                    await self?.fetchChartData(for: coin.symbol)
                }
            }
        }
    }
    
    // MARK: - Private Methods
    @MainActor
    private func fetchPredefinedCoins() async {
        do {
            let ids = CoinData.predefinedCoins.map(\.id)
            let coins = try await coinScannerService.getCoins(by: ids)
            for coin in coins {
                await saveCoin(coin)
            }
        } catch {
            setErrorMessage(error)
        }
    }
    
    private func startCacheTimer() {
        cacheTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.clearCacheIfNeeded()
        }
    }
}
