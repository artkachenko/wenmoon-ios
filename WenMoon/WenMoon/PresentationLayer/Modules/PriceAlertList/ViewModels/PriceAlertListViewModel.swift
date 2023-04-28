//
//  PriceAlertListViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation
import Combine

final class PriceAlertListViewModel: ObservableObject {

    // MARK: - Properties

    @Published private(set) var priceAlerts: [PriceAlert] = []
    @Published private(set) var marketData: [String: CoinMarketData] = [:]
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    private let service: CoinScannerService
    private let persistence: PersistenceManager

    private var timer: Timer?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializers

    convenience init() {
        self.init(service: CoinScannerServiceImpl(), persistence: PersistenceManagerImpl())
    }

    init(service: CoinScannerService, persistence: PersistenceManager) {
        self.service = service
        self.persistence = persistence

        persistence.errorPublisher.sink { [weak self] error in
            self?.errorMessage = error.errorDescription
        }
        .store(in: &cancellables)
    }

    // MARK: - Methods

    func fetchMarketData(for coins: [Coin]) {
        let coinIDs = coins.map { $0.id }
        let existingMarketData = coinIDs.compactMap { marketData[$0] }

        if existingMarketData.count == coins.count {
            return
        }

        isLoading = true
        service.getMarketData(for: coinIDs)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.errorDescription
                case .finished: break
                }
            }, receiveValue: { [weak self] marketData in
                self?.marketData.merge(marketData, uniquingKeysWith: { $1 })
                self?.savePriceAlerts(coins, marketData)
                self?.scheduleClearCache()
            })
            .store(in: &cancellables)
    }

    func fetchPriceAlerts() {
        let sortDescriptors = [NSSortDescriptor(keyPath: \PriceAlert.rank, ascending: true)]
        let request = PriceAlert.fetchRequest(sortDescriptors: sortDescriptors)
        if let priceAlerts = persistence.fetch(request) {
            self.priceAlerts = priceAlerts
        }

        if !priceAlerts.isEmpty {
            let coins = priceAlerts.map { Coin(priceAlert: $0) }
            fetchMarketData(for: coins)
        }
    }

    func delete(_ priceAlert: PriceAlert) {
        persistence.delete(priceAlert)
        if let index = priceAlerts.firstIndex(of: priceAlert) {
            priceAlerts.remove(at: index)
        }
    }

    func savePriceAlerts(_ coins: [Coin], _ marketData: [String: CoinMarketData]) {
        persistence.context.perform { [weak self] in
            let batchSize = 50
            var offset = 0

            while offset < coins.count {
                let batchCoins = Array(coins[offset..<min(offset + batchSize, coins.count)])
                let predicate = NSPredicate(format: "id IN %@", batchCoins.map { $0.id })
                let request = PriceAlert.fetchRequest(predicate: predicate)
                let existingPriceAlerts = self?.persistence.fetch(request)

                for coin in batchCoins {
                    guard let marketData = marketData[coin.id] else { continue }

                    if let existingPriceAlert = existingPriceAlerts?.first(where: { $0.id == coin.id }) {
                        self?.setData(for: existingPriceAlert, with: coin, marketData)
                    } else {
                        self?.createNewPriceAlert(coin, marketData)
                    }
                }
                offset += batchSize
            }
            self?.persistence.save()
        }
    }

    private func createNewPriceAlert(_ coin: Coin, _ marketData: CoinMarketData) {
        let newPriceAlert = PriceAlert(context: persistence.context)
        setData(for: newPriceAlert, with: coin, marketData) { [weak self] in
            self?.priceAlerts.append(newPriceAlert)
            self?.priceAlerts.sort(by: { $0.rank < $1.rank })
        }
    }

    private func setData(for priceAlert: PriceAlert,
                         with coin: Coin,
                         _ marketData: CoinMarketData,
                         completion: (() -> Void)? = nil) {
        priceAlert.id = coin.id
        priceAlert.name = coin.name
        priceAlert.image = coin.image
        priceAlert.rank = coin.marketCapRank
        priceAlert.currentPrice = marketData.usd
        priceAlert.priceChange = marketData.usd24HChange

        if let url = URL(string: coin.image) {
            URLSession.shared.dataTask(with: url) { [weak self] (imageData, _, error) in
                guard let imageData, error == nil else {
                    self?.errorMessage = "Error downloading image for \(coin.name): \(error!.localizedDescription)"
                    return
                }
                priceAlert.imageData = imageData
                DispatchQueue.main.async {
                    completion?()
                }
            }.resume()
        } else {
            errorMessage = "Invalid image URL for \(coin.name)"
        }
    }

    private func scheduleClearCache() {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 20, repeats: false) { [weak self] _ in
                self?.marketData.removeAll()
                self?.timer?.invalidate()
                self?.timer = nil
            }
        }
    }
}
