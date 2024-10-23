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
    private var timer: Timer?
    
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
    }
    
    // MARK: - Interface
    func fetchCoins() async {
        if isFirstLaunch {
            await fetchPredefinedCoins()
        } else {
            let descriptor = FetchDescriptor<CoinData>(sortBy: [SortDescriptor(\.rank)])
            coins = fetch(descriptor)
        }
    }
    
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
                    coins[index].priceChange = coinMarketData.priceChange ?? .zero
                }
            }
            save()
        } catch {
            setErrorMessage(error)
        }
    }
    
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
    
    func saveCoin(_ coin: Coin) async {
        if !coins.contains(where: { $0.id == coin.id }) {
            let newCoin = CoinData()
            newCoin.id = coin.id
            newCoin.name = coin.name
            newCoin.imageURL = coin.imageURL
            newCoin.rank = coin.marketCapRank ?? .max
            newCoin.currentPrice = coin.currentPrice ?? .zero
            newCoin.priceChange = coin.priceChangePercentage24H ?? .zero
            newCoin.targetPrice = nil
            newCoin.isActive = false
            if let url = coin.imageURL {
                newCoin.imageData = await loadImage(from: url)
            }
            insertAndSave(newCoin)
        }
    }
    
    func deleteCoin(_ coin: CoinData) async {
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
    
    // MARK: - Private
    private func fetchPredefinedCoins() async {
        let predefinedCoins = CoinData.predefinedCoins
        for coin in predefinedCoins {
            if let url = coin.imageURL {
                coin.imageData = await loadImage(from: url)
            }
            insertAndSave(coin)
        }
        self.coins = predefinedCoins
    }
    
    private func insertAndSave(_ coin: CoinData) {
        coins.append(coin)
        insert(coin)
    }
    
    private func setPriceAlert(_ targetPrice: Double, for coin: CoinData) async {
        guard let deviceToken else { return }
        do {
            let priceAlert = try await priceAlertService.setPriceAlert(targetPrice, for: coin, deviceToken: deviceToken)
            coin.targetPrice = targetPrice
            coin.isActive = true
        } catch {
            coin.targetPrice = nil
            coin.isActive = false
            setErrorMessage(error)
        }
    }
    
    private func deletePriceAlert(for coin: CoinData) async {
        guard let deviceToken else { return }
        do {
            let priceAlert = try await priceAlertService.deletePriceAlert(for: coin.id, deviceToken: deviceToken)
            coin.targetPrice = nil
            coin.isActive = false
        } catch {
            setErrorMessage(error)
        }
    }
}
