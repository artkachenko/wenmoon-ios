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
    private let coinScannerService: CoinScannerService
    private let priceAlertService: PriceAlertService
    
    @Published var coins: [CoinData] = []
    @Published var marketData: [String: MarketData] = [:]
    @Published var globalMarketItems: [GlobalMarketItem] = []
    @Published var selectedSortOption: SortOption = .marketCap
    
    private var cacheTimer: Timer?
    
    // MARK: - Initializers
    convenience init() {
        self.init(
            coinScannerService: CoinScannerServiceImpl(),
            priceAlertService: PriceAlertServiceImpl()
        )
    }
    
    init(
        coinScannerService: CoinScannerService,
        priceAlertService: PriceAlertService,
        firebaseAuthService: FirebaseAuthService? = nil,
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
    }
    
    // MARK: - Internal Methods
    @MainActor
    func fetchCoins() async {
        let descriptor = FetchDescriptor<CoinData>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.marketCapRank)]
        )
        let fetchedCoins = fetch(descriptor)
        coins = fetchedCoins
        await fetchMarketData()
        getSavedSortOption()
        sortCoinsBySavedOrder()
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
                    coins[index].updateMarketData(from: coinMarketData)
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
            deleteCoin(coin)
        }
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
    
    // Sorting
    func sortCoins(by sortOption: SortOption? = nil) {
        let sortOption = sortOption ?? selectedSortOption
        switch sortOption {
        case .symbol:
            coins.sort(by: sortByName)
        case .marketCap:
            coins.sort(by: sortByMarketCap)
        case .priceChange24H:
            coins.sort(by: sortByPriceChange)
        case .custom:
            sortCoinsBySavedOrder(for: .custom)
        }
        saveSortOption(sortOption)
        saveCoinsOrder(for: sortOption)
    }
    
    func saveSortOption(_ sortOption: SortOption) {
        try? userDefaultsManager.setObject(sortOption.rawValue, forKey: .sortOption)
        selectedSortOption = sortOption
    }
    
    func saveCoinsOrder(for sortOption: SortOption) {
        let coinIDs = coins.map { $0.id }
        try? userDefaultsManager.setObject(coinIDs, forKey: .coinsOrder(forOption: sortOption))
    }
    
    // MARK: - Private Methods
    @MainActor
    private func insertCoin(_ coin: Coin) async {
        print("Inserting coin: \(coin.id)")
        let imageData = coin.image != nil ? await loadImage(from: coin.image!) : nil
        let newCoin = CoinData(from: coin, imageData: imageData)
        coins.append(newCoin)
        insert(newCoin)
    }
    
    private func deleteCoin(_ coin: CoinData) {
        print("Deleting coin: \(coin.id)")
        if let index = coins.firstIndex(of: coin) {
            coins.remove(at: index)
        }
        delete(coin)
    }
    
    private func archiveCoin(_ coin: CoinData) {
        print("Archiving coin: \(coin.id)")
        coin.isArchived = true
        if let index = coins.firstIndex(of: coin) {
            coins.remove(at: index)
        }
        save()
    }
    
    private func unarchiveCoin(_ coin: CoinData) {
        print("Unarchiving coin: \(coin.id)")
        coin.isArchived = false
        coins.append(coin)
        save()
    }
    
    private func startCacheTimer() {
        cacheTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.clearCacheIfNeeded()
        }
    }
    
    // Sorting
    private func getSavedSortOption() {
        if let rawValue = try? userDefaultsManager.getObject(forKey: .sortOption, objectType: String.self),
           let savedSortOption = SortOption(rawValue: rawValue) {
            selectedSortOption = savedSortOption
        }
    }
    
    private func sortCoinsBySavedOrder(for sortOption: SortOption? = nil) {
        let sortOption = sortOption ?? selectedSortOption
        if let savedOrder = try? userDefaultsManager.getObject(forKey: .coinsOrder(forOption: sortOption), objectType: [String].self) {
            coins.sort { coin1, coin2 in
                let index1 = savedOrder.firstIndex(of: coin1.id) ?? .max
                let index2 = savedOrder.firstIndex(of: coin2.id) ?? .max
                return index1 < index2
            }
        }
    }
    
    private func sortByName(_ coin1: CoinData, _ coin2: CoinData) -> Bool {
        coin1.symbol.lowercased() < coin2.symbol.lowercased()
    }
    
    private func sortByRank(_ coin1: CoinData, _ coin2: CoinData) -> Bool {
        (coin1.marketCapRank ?? .max) < (coin2.marketCapRank ?? .max)
    }
    
    private func sortByMarketCap(_ coin1: CoinData, _ coin2: CoinData) -> Bool {
        (coin1.marketCap ?? .zero) > (coin2.marketCap ?? .zero)
    }
    
    private func sortByPriceChange(_ coin1: CoinData, _ coin2: CoinData) -> Bool {
        (coin1.priceChangePercentage24H ?? .zero) > (coin2.priceChangePercentage24H ?? .zero)
    }
}

struct GlobalMarketItem: Hashable {
    // MARK: - Nested Types
    enum ItemType: CaseIterable {
        case btcDominance
        case ethDominance
        case othersDominance
        case cpi
        case nextCPI
        case interestRate
        case nextFOMCMeeting
        
        var title: String {
            switch self {
            case .btcDominance: return "BTC.D:"
            case .ethDominance: return "ETH.D:"
            case .othersDominance: return "OTHERS.D:"
            case .cpi: return "CPI:"
            case .nextCPI: return "Next CPI:"
            case .interestRate: return "Interest Rate:"
            case .nextFOMCMeeting: return "Next FOMC:"
            }
        }
    }
    
    // MARK: - Properties
    let type: ItemType
    let value: String
}

enum SortOption: String, CaseIterable {
    case symbol
    case marketCap
    case priceChange24H
    case custom
    
    var title: String {
        switch self {
        case .symbol: return "Symbol"
        case .marketCap: return "Market Cap"
        case .priceChange24H: return "24h Change"
        case .custom: return "Custom"
        }
    }
}
