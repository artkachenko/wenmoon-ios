//
//  CoinListViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

final class CoinListViewModel: BaseViewModel {

    // MARK: - Properties

    @Published var coins: [CoinEntity] = []
    @Published private(set) var marketData: [String: MarketData] = [:]

    private let coinScannerService: CoinScannerService
    private let priceAlertService: PriceAlertService
    private var timer: Timer?

    // MARK: - Initializers

    convenience init() {
        self.init(coinScannerService: CoinScannerServiceImpl(), priceAlertService: PriceAlertServiceImpl())
    }

    init(coinScannerService: CoinScannerService, priceAlertService: PriceAlertService) {
        self.coinScannerService = coinScannerService
        self.priceAlertService = priceAlertService
        super.init(persistenceManager: PersistenceManagerImpl(), userDefaultsManager: UserDefaultsManagerImpl())
    }

    // MARK: - Methods

    func fetchCoins() {
        let isActiveSortDescriptor = NSSortDescriptor(keyPath: \CoinEntity.isActive, ascending: false)
        let rankSortDescriptor = NSSortDescriptor(keyPath: \CoinEntity.rank, ascending: true)

        let sortDescriptors = [isActiveSortDescriptor, rankSortDescriptor]
        let request = CoinEntity.fetchRequest(sortDescriptors: sortDescriptors)

        if let coins = try? persistenceManager.fetch(request) {
            self.coins = coins
        }

        if !coins.isEmpty {
            Task {
                await fetchMarketData()
                await fetchPriceAlerts()
            }
        }
    }

    func createCoinEntity(_ coin: Coin, _ marketData: MarketData? = nil) {
        if !coins.contains(where: { $0.id == coin.id }) {
            let newCoin = CoinEntity(context: persistenceManager.context)
            newCoin.id = coin.id
            newCoin.name = coin.name
            newCoin.image = coin.image
            newCoin.rank = coin.marketCapRank ?? .max
            newCoin.targetPrice = nil
            newCoin.isActive = false

            if let marketData {
                newCoin.currentPrice = marketData.currentPrice ?? .zero
                newCoin.priceChange = marketData.priceChange ?? .zero
            } else {
                newCoin.currentPrice = coin.currentPrice ?? .zero
                newCoin.priceChange = coin.priceChangePercentage24H ?? .zero
            }

            if let url = URL(string: coin.image) {
                Task {
                    do {
                        let imageData = try await loadImage(from: url)
                        newCoin.imageData = imageData
                        coins.append(newCoin)
                        sortCoins()
                        saveChanges()
                    } catch {
                        errorMessage = "Error downloading image for \(coin.name): \(error.localizedDescription)"
                    }
                }
            } else {
                errorMessage = "Invalid image URL for \(coin.name)"
            }
        }
    }

    func deleteCoin(_ coin: CoinEntity) {
        do {
            try persistenceManager.delete(coin)
            if let index = coins.firstIndex(of: coin) {
                coins.remove(at: index)
            }
        } catch {
            errorMessage = "Error deleting coin: \(error.localizedDescription)"
        }
    }

    func setPriceAlert(for coin: CoinEntity, targetPrice: Double?) {
        if let targetPrice {
            coin.targetPrice = NSNumber(value: targetPrice)
            coin.isActive = true
            Task {
                await setPriceAlert(for: coin)
            }
        } else {
            coin.targetPrice = nil
            coin.isActive = false
            Task {
                await deletePriceAlert(for: coin.id)
            }
        }

        sortCoins()
        saveChanges()
    }

    func toggleOffPriceAlert(for id: String) {
        if let index = coins.firstIndex(where: { $0.id == id }) {
            coins[index].targetPrice = nil
            coins[index].isActive = false
        }
        saveChanges()
    }

    @MainActor
    private func fetchPriceAlerts() async {
        guard let deviceToken else { return }
        do {
            let priceAlerts = try await priceAlertService.getPriceAlerts(deviceToken: deviceToken)
            for (index, coin) in coins.enumerated() {
                if let matchingPriceAlert = priceAlerts.first(where: { $0.coinId == coin.id }) {
                    coins[index].targetPrice = NSNumber(value: matchingPriceAlert.targetPrice)
                    coins[index].isActive = true
                } else {
                    coins[index].targetPrice = nil
                    coins[index].isActive = false
                }
            }
            saveChanges()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func setPriceAlert(for coin: CoinEntity) async {
        guard let deviceToken else { return }
        do {
            let priceAlert = try await priceAlertService.setPriceAlert(for: coin, deviceToken: deviceToken)
            print("Successfully set price alert for \(priceAlert.coinName) with target price \(priceAlert.targetPrice)")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func deletePriceAlert(for id: String) async {
        guard let deviceToken else { return }
        do {
            let priceAlert = try await priceAlertService.deletePriceAlert(for: id, deviceToken: deviceToken)
            print("Successfully deleted price alert for \(priceAlert.coinName)")
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    @MainActor
    private func fetchMarketData() async {
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
            saveChanges()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func sortCoins() {
        coins.sort { coin1, coin2 in
            if coin1.isActive != coin2.isActive {
                return coin1.isActive && !coin2.isActive
            }
            return coin1.rank < coin2.rank
        }
    }
}
