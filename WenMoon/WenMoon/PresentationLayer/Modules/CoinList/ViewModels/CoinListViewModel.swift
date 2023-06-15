//
//  CoinListViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation
import Combine

final class CoinListViewModel: ObservableObject {

    // MARK: - Properties

    @Published var coins: [CoinEntity] = []
    @Published private(set) var marketData: [String: MarketData] = [:]
    @Published private(set) var errorMessage: String?

    private let coinScannerService: CoinScannerService
    private let priceAlertService: PriceAlertService
    private let persistenceManager: PersistenceManager
    private let userDefaultsManager: UserDefaultsManager

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    private var deviceToken: String? {
        userDefaultsManager.getObject(forKey: "deviceToken", objectType: String.self)
    }

    // MARK: - Initializers

    convenience init() {
        self.init(coinScannerService: CoinScannerServiceImpl(),
                  priceAlertService: PriceAlertServiceImpl(),
                  persistenceManager: PersistenceManagerImpl(),
                  userDefaultsManager: UserDefaultsManagerImpl())
    }

    init(coinScannerService: CoinScannerService,
         priceAlertService: PriceAlertService,
         persistenceManager: PersistenceManager,
         userDefaultsManager: UserDefaultsManager) {
        self.coinScannerService = coinScannerService
        self.priceAlertService = priceAlertService
        self.persistenceManager = persistenceManager
        self.userDefaultsManager = userDefaultsManager

        persistenceManager.errorPublisher.sink { [weak self] error in
            self?.errorMessage = error.errorDescription
        }
        .store(in: &cancellables)

        userDefaultsManager.errorPublisher.sink { [weak self] error in
            self?.errorMessage = error.errorDescription
        }
        .store(in: &cancellables)
    }

    // MARK: - Methods

    func fetchCoins() {
        let sortDescriptors = [NSSortDescriptor(keyPath: \CoinEntity.rank, ascending: true)]
        let request = CoinEntity.fetchRequest(sortDescriptors: sortDescriptors)
        if let coins = persistenceManager.fetch(request) {
            self.coins = coins
        }

        if !coins.isEmpty {
            fetchMarketData()
            fetchPriceAlerts()
        }
    }

    func createCoinEntity(_ coin: Coin, _ marketData: MarketData? = nil) {
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
            loadImage(from: url)
                .sink(receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.errorMessage = "Error downloading image for \(coin.name): \(error.localizedDescription)"
                    case .finished:
                        print("Image loading completed successfully")
                    }
                }, receiveValue: { [weak self] imageData in
                    newCoin.imageData = imageData

                    DispatchQueue.main.async {
                        self?.coins.append(newCoin)
                        self?.coins.sort(by: { $0.rank < $1.rank })
                    }
                })
                .store(in: &cancellables)
        } else {
            errorMessage = "Invalid image URL for \(coin.name)"
        }
        saveChanges()
    }

    func deleteCoin(_ coin: CoinEntity) {
        persistenceManager.delete(coin)
        if let index = coins.firstIndex(of: coin) {
            coins.remove(at: index)
        }
    }

    func setPriceAlert(for coin: CoinEntity, targetPrice: Double?) {
        if let targetPrice {
            coin.targetPrice = NSNumber(value: targetPrice)
            coin.isActive = true
            setPriceAlert(for: coin)
        } else {
            coin.targetPrice = nil
            coin.isActive = false
            deletePriceAlert(for: coin.id)
        }
        saveChanges()
    }

    func toggleOffPriceAlert(for id: String) {
        if let index = coins.firstIndex(where: { $0.id == id }) {
            coins[index].targetPrice = nil
            coins[index].isActive = false
        }
        saveChanges()
    }

    private func fetchPriceAlerts() {
        guard let deviceToken else { return }
        priceAlertService.getPriceAlerts(deviceToken: deviceToken)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.errorDescription
                case .finished: break
                }
            }, receiveValue: { [weak self] priceAlerts in
                guard let self else { return }

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
            })
            .store(in: &cancellables)
    }

    private func setPriceAlert(for coin: CoinEntity) {
        guard let deviceToken else { return }
        priceAlertService.setPriceAlert(for: coin, deviceToken: deviceToken)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.errorDescription
                case .finished: break
                }
            }, receiveValue: { priceAlert in
                print("Successfully set price alert for \(priceAlert.coinName) with target price \(priceAlert.targetPrice)")
            })
            .store(in: &cancellables)
    }

    private func deletePriceAlert(for id: String) {
        guard let deviceToken else { return }
        priceAlertService.deletePriceAlert(for: id, deviceToken: deviceToken)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.errorDescription
                case .finished: break
                }
            }, receiveValue: { priceAlert in
                print("Successfully delete price alert for \(priceAlert.coinName)")
            })
            .store(in: &cancellables)
    }

    private func fetchMarketData() {
        let coinIDs = coins.map { $0.id }
        let existingMarketData = coinIDs.compactMap { marketData[$0] }

        guard existingMarketData.count != coins.count else { return }

        coinScannerService.getMarketData(for: coinIDs)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.errorDescription
                case .finished: break
                }
            }, receiveValue: { [weak self] marketData in
                for (index, coinID) in coinIDs.enumerated() {
                    if let coinMarketData = marketData[coinID] {
                        self?.marketData[coinID] = coinMarketData
                        self?.coins[index].currentPrice = coinMarketData.currentPrice ?? .zero
                        self?.coins[index].priceChange = coinMarketData.priceChange ?? .zero
                    }
                }

                self?.saveChanges()
            })
            .store(in: &cancellables)
    }

    private func saveChanges() {
        persistenceManager.save()
        objectWillChange.send()
    }

    private func loadImage(from url: URL) -> AnyPublisher<Data, Error> {
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
