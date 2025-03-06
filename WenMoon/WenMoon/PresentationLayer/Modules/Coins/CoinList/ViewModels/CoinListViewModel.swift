//
//  CoinListViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation
import SwiftData
import SwiftUI

final class CoinListViewModel: BaseViewModel {
    // MARK: - Properties
    private let priceAlertsViewModel: PriceAlertsViewModel
    private let coinScannerService: CoinScannerService
    
    @Published var coins: [CoinData] = []
    @Published var marketData: [String: MarketData] = [:]
    
    var pinnedCoins: [CoinData] { coins.filter { $0.isPinned } }
    var unpinnedCoins: [CoinData] { coins.filter { !$0.isPinned } }
    
    // MARK: - Initializers
    convenience init() {
        self.init(
            priceAlertsViewModel: PriceAlertsViewModel(),
            coinScannerService: CoinScannerServiceImpl()
        )
    }
    
    init(
        priceAlertsViewModel: PriceAlertsViewModel,
        coinScannerService: CoinScannerService,
        appLaunchProvider: AppLaunchProvider? = nil,
        userDefaultsManager: UserDefaultsManager? = nil,
        swiftDataManager: SwiftDataManager? = nil
    ) {
        self.priceAlertsViewModel = priceAlertsViewModel
        self.coinScannerService = coinScannerService
        super.init(
            appLaunchProvider: appLaunchProvider,
            userDefaultsManager: userDefaultsManager,
            swiftDataManager: swiftDataManager
        )
        startCacheTimer(interval: 180) { [weak self] in
            self?.clearCacheIfNeeded()
        }
    }
    
    // MARK: - Internal Methods
    @MainActor
    func fetchCoins(_ isRefreshing: Bool = false) async {
        if isFirstLaunch {
            let predefinedCoins = CoinData.predefinedCoins
            coins = predefinedCoins
            for coin in predefinedCoins {
                insert(coin)
                saveCoinsOrder()
            }
        } else {
            let descriptor = FetchDescriptor<CoinData>(
                predicate: #Predicate { !$0.isArchived },
                sortBy: [SortDescriptor(\.marketCap)]
            )
            let fetchedCoins = fetch(descriptor)
            
            if let savedOrder = try? userDefaultsManager.getObject(forKey: .coinsOrder, objectType: [String].self) {
                coins = fetchedCoins.sorted { coin1, coin2 in
                    let index1 = savedOrder.firstIndex(of: coin1.id) ?? .max
                    let index2 = savedOrder.firstIndex(of: coin2.id) ?? .max
                    return index1 < index2
                }
            } else {
                coins = fetchedCoins
            }
        }
        
        await fetchMarketData(isRefreshing)
    }
    
    @MainActor
    func fetchMarketData(_ isRefreshing: Bool = false) async {
        let coinIDs = coins.map { $0.id }
        let existingMarketData = coinIDs.compactMap { marketData[$0] }
        
        guard existingMarketData.count != coins.count else { return }
        
        do {
            let fetchedMarketData = try await coinScannerService.getMarketData(for: coinIDs)
            for (index, coinID) in coinIDs.enumerated() {
                if let coinMarketData = fetchedMarketData[coinID] {
                    marketData[coinID] = coinMarketData
                    coins[index].updateMarketData(from: coinMarketData)
                }
            }
            save()
            
            if !isRefreshing {
                triggerImpactFeedback()
            }
        } catch {
            setError(error)
        }
    }
    
    @MainActor
    func fetchPriceAlerts() async {
        guard !coins.isEmpty else { return }
        let priceAlerts = await priceAlertsViewModel.fetchPriceAlerts()
        for (index, coin) in coins.enumerated() {
            let matchingPriceAlerts = priceAlerts.filter { $0.coinID == coin.id }
            coins[index].priceAlerts = matchingPriceAlerts
        }
    }
    
    @MainActor
    func saveCoin(_ coin: Coin) async {
        let descriptor = FetchDescriptor<CoinData>(predicate: #Predicate { $0.id == coin.id })
        let fetchedCoins = fetch(descriptor)
        
        if let existingCoin = fetchedCoins.first {
            if existingCoin.isArchived {
                unarchiveCoin(existingCoin)
            }
            return
        }
        
        await insertCoin(coin)
    }
    
    @MainActor
    func deleteCoin(_ coinID: String) async {
        guard let coin = coins.first(where: { $0.id == coinID }) else { return }
        
        let descriptor = FetchDescriptor<Portfolio>()
        let portfolios = fetch(descriptor)
        
        var isCoinReferenced = false
        for portfolio in portfolios {
            if portfolio.transactions.contains(where: { $0.coinID == coin.id }) {
                isCoinReferenced = true
                break
            }
        }
        
        if isCoinReferenced {
            archiveCoin(coin)
        } else {
            removeCoin(coin)
        }
    }
    
    func deactivatePriceAlert(_ id: String) {
        coins.forEach { coin in
            if let alertIndex = coin.priceAlerts.firstIndex(where: { $0.id == id }) {
                coin.priceAlerts[alertIndex].isActive = false
                save()
                return
            }
        }
    }
    
    func pinCoin(_ coin: CoinData) {
        if let index = coins.firstIndex(where: { $0.id == coin.id }) {
            withAnimation {
                coins[index].isPinned = true
                sortCoins()
                saveCoinsOrder()
            }
        }
    }
    
    func unpinCoin(_ coin: CoinData) {
        if let index = coins.firstIndex(where: { $0.id == coin.id }) {
            withAnimation {
                coins[index].isPinned = false
                sortCoins()
                saveCoinsOrder()
            }
        }
    }
    
    func moveCoin(from source: IndexSet, to destination: Int, isPinned: Bool) {
        var filteredCoins = coins.filter { $0.isPinned == isPinned }
        filteredCoins.move(fromOffsets: source, toOffset: destination)
        
        let otherCoins = coins.filter { $0.isPinned != isPinned }
        withAnimation {
            coins = isPinned ? (filteredCoins + otherCoins) : (otherCoins + filteredCoins)
        }
        saveCoinsOrder()
    }
    
    // MARK: - Private Methods
    @MainActor
    private func insertCoin(_ coin: Coin) async {
        let imageData = coin.image != nil ? await loadImage(from: coin.image!) : nil
        let newCoin = CoinData(from: coin, imageData: imageData)
        withAnimation {
            coins.append(newCoin)
        }
        insert(newCoin)
        sortCoins()
        saveCoinsOrder()
    }
    
    private func removeCoin(_ coin: CoinData) {
        withAnimation {
            if let index = coins.firstIndex(of: coin) {
                coins.remove(at: index)
            }
        }
        marketData.removeValue(forKey: coin.id)
        delete(coin)
        saveCoinsOrder()
    }
    
    private func archiveCoin(_ coin: CoinData) {
        withAnimation {
            coin.isPinned = false
            coin.isArchived = true
            if let index = coins.firstIndex(of: coin) {
                coins.remove(at: index)
            }
        }
        save()
        saveCoinsOrder()
    }
    
    private func unarchiveCoin(_ coin: CoinData) {
        coin.isArchived = false
        withAnimation {
            coins.append(coin)
        }
        save()
        saveCoinsOrder()
    }
    
    private func saveCoinsOrder() {
        let coinIDs = coins.map { $0.id }
        try? userDefaultsManager.setObject(coinIDs, forKey: .coinsOrder)
    }
    
    private func sortCoins() {
        withAnimation {
            coins.sort { coin1, coin2 in
                if coin1.isPinned != coin2.isPinned {
                    return coin1.isPinned
                }
                return (coin1.marketCap ?? .zero) > (coin2.marketCap ?? .zero)
            }
        }
    }
    
    private func clearCacheIfNeeded() {
        if !marketData.isEmpty {
            marketData.removeAll()
        }
    }
}
