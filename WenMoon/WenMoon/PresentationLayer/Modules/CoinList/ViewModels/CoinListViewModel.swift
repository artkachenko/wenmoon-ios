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
    
    private let coinScannerService: CoinScannerService
    private let priceAlertService: PriceAlertService
    private var cacheTimer: Timer?
    
    // MARK: - Initializers
    convenience init() {
        if let modelContainer = try? ModelContainer(for: CoinData.self) {
            let swiftDataManager = SwiftDataManagerImpl(modelContainer: modelContainer)
            self.init(
                coinScannerService: CoinScannerServiceImpl(),
                priceAlertService: PriceAlertServiceImpl(),
                userDefaultsManager: UserDefaultsManagerImpl(),
                swiftDataManager: swiftDataManager
            )
        } else {
            self.init(
                coinScannerService: CoinScannerServiceImpl(),
                priceAlertService: PriceAlertServiceImpl(),
                userDefaultsManager: UserDefaultsManagerImpl()
            )
        }
    }
    
    init(
        coinScannerService: CoinScannerService,
        priceAlertService: PriceAlertService,
        userDefaultsManager: UserDefaultsManager,
        swiftDataManager: SwiftDataManager? = nil
    ) {
        self.coinScannerService = coinScannerService
        self.priceAlertService = priceAlertService
        super.init(swiftDataManager: swiftDataManager, userDefaultsManager: userDefaultsManager)
        
        startCacheTimer()
    }
    
    deinit {
        cacheTimer?.invalidate()
    }
    
    // MARK: - Internal Methods
    @MainActor
    func fetchCoins() async {
        if isFirstLaunch {
            await fetchPredefinedCoins()
        } else {
            let descriptor = FetchDescriptor<CoinData>()
            coins = fetch(descriptor)
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
                    coins[index].priceChangePercentage24H = coinMarketData.priceChangePercentage24H ?? .zero
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
            print("Cache cleared.")
        }
    }
    
    @MainActor
    func fetchPriceAlerts() async {
        guard let deviceToken, !coins.isEmpty else { return }
        do {
            let priceAlerts = try await priceAlertService.getPriceAlerts(deviceToken: deviceToken)
            for (index, coin) in coins.enumerated() {
                if let matchingPriceAlert = priceAlerts.first(where: { $0.coinId == coin.id }) {
                    coins[index].targetPrice = matchingPriceAlert.targetPrice
                    coins[index].isActive = true
                } else {
                    coins[index].targetPrice = nil
                    coins[index].isActive = false
                }
            }
            save()
        } catch {
            setErrorMessage(error)
        }
    }
    
    @MainActor
    func saveCoin(_ coin: Coin) async {
        if !coins.contains(where: { $0.id == coin.id }) {
            let newCoin = CoinData()
            newCoin.id = coin.id
            newCoin.name = coin.name
            newCoin.rank = coin.marketCapRank ?? .max
            newCoin.currentPrice = coin.currentPrice ?? .zero
            newCoin.priceChangePercentage24H = coin.priceChangePercentage24H ?? .zero
            newCoin.targetPrice = nil
            newCoin.isActive = false
            
            if let url = coin.image {
                newCoin.imageData = await loadImage(from: url)
            }
            
            coins.append(newCoin)
            insert(newCoin)
        }
    }
    
    @MainActor
    func deleteCoin(_ coinID: String) async {
        guard let coin = coins.first(where: { $0.id == coinID }) else { return }
        if coin.targetPrice != nil {
            await deletePriceAlert(for: coin)
        }
        
        if let index = coins.firstIndex(of: coin) {
            coins.remove(at: index)
        }
        
        delete(coin)
    }
    
    func setPriceAlert(for coin: CoinData, targetPrice: Double?) async {
        if let targetPrice {
            await setPriceAlert(targetPrice, for: coin)
        } else {
            await deletePriceAlert(for: coin)
        }
        save()
    }
    
    // When the target price has been reached
    func toggleOffPriceAlert(for id: String) {
        if let index = coins.firstIndex(where: { $0.id == id }) {
            coins[index].targetPrice = nil
            coins[index].isActive = false
        }
        save()
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
    
    @MainActor
    private func setPriceAlert(_ targetPrice: Double, for coin: CoinData) async {
        guard let deviceToken else { return }
        do {
            let _ = try await priceAlertService.setPriceAlert(targetPrice, for: coin, deviceToken: deviceToken)
            coin.targetPrice = targetPrice
            coin.isActive = true
        } catch {
            coin.targetPrice = nil
            coin.isActive = false
            setErrorMessage(error)
        }
    }
    
    @MainActor
    private func deletePriceAlert(for coin: CoinData) async {
        guard let deviceToken else { return }
        do {
            let _ = try await priceAlertService.deletePriceAlert(for: coin.id, deviceToken: deviceToken)
            coin.targetPrice = nil
            coin.isActive = false
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
