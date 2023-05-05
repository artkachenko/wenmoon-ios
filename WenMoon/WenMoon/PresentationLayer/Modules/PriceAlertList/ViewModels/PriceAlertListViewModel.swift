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

    @Published var priceAlerts: [PriceAlert] = []
    @Published private(set) var marketData: [String: CoinMarketData] = [:]
    @Published private(set) var errorMessage: String?

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

    func fetchPriceAlerts() {
        let sortDescriptors = [NSSortDescriptor(keyPath: \PriceAlert.rank, ascending: true)]
        let request = PriceAlert.fetchRequest(sortDescriptors: sortDescriptors)
        if let priceAlerts = persistence.fetch(request) {
            self.priceAlerts = priceAlerts
        }

        if !priceAlerts.isEmpty {
            fetchMarketData(for: priceAlerts)
        }
    }

    func createNewPriceAlert(from coin: Coin,
                             marketData: CoinMarketData? = nil,
                             targetPrice: Double? = nil) {
        guard let priceAlert = priceAlerts.first(where: { $0.id == coin.id }) else {
            let newPriceAlert = PriceAlert(context: persistence.context)
            newPriceAlert.id = coin.id
            newPriceAlert.name = coin.name
            newPriceAlert.image = coin.image
            newPriceAlert.rank = coin.marketCapRank ?? .max

            if let targetPrice {
                newPriceAlert.targetPrice = NSNumber(value: targetPrice)
                newPriceAlert.isActive = true
            } else {
                newPriceAlert.isActive = false
            }

            if let marketData {
                newPriceAlert.currentPrice = marketData.currentPrice ?? .zero
                newPriceAlert.priceChange = marketData.priceChange ?? .zero
            } else {
                newPriceAlert.currentPrice = coin.currentPrice ?? .zero
                newPriceAlert.priceChange = coin.priceChangePercentage24H ?? .zero
            }

            if let url = URL(string: coin.image) {
                URLSession.shared.dataTask(with: url) { [weak self] (imageData, _, error) in
                    guard let imageData, error == nil else {
                        self?.errorMessage = "Error downloading image for \(coin.name): \(error!.localizedDescription)"
                        return
                    }
                    newPriceAlert.imageData = imageData

                    DispatchQueue.main.async {
                        self?.priceAlerts.append(newPriceAlert)
                        self?.priceAlerts.sort(by: { $0.rank < $1.rank })
                    }
                }.resume()
            } else {
                errorMessage = "Invalid image URL for \(coin.name)"
            }

            persistence.save()
            return
        }

        if let targetPrice {
            setPriceAlert(priceAlert, targetPrice: targetPrice)
        }
    }

    func delete(_ priceAlert: PriceAlert) {
        persistence.delete(priceAlert)
        if let index = priceAlerts.firstIndex(of: priceAlert) {
            priceAlerts.remove(at: index)
        }
    }

    func setPriceAlert(_ priceAlert: PriceAlert, targetPrice: Double?) {
        if let targetPrice {
            priceAlert.isActive = true
            priceAlert.targetPrice = NSNumber(value: targetPrice)
        } else {
            priceAlert.isActive = false
            priceAlert.targetPrice = nil
        }
        persistence.save()
        objectWillChange.send()
    }

    private func fetchMarketData(for priceAlerts: [PriceAlert]) {
        let coinIDs = priceAlerts.map { $0.id }
        let existingMarketData = coinIDs.compactMap { marketData[$0] }

        if existingMarketData.count == priceAlerts.count {
            return
        }

        service.getMarketData(for: coinIDs)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.errorDescription
                case .finished: break
                }
            }, receiveValue: { [weak self] marketData in
                self?.marketData.merge(marketData, uniquingKeysWith: { $1 })
                self?.updatePriceAlerts(priceAlerts, marketData)
                self?.scheduleClearCache()
            })
            .store(in: &cancellables)
    }

    private func updatePriceAlerts(_ priceAlerts: [PriceAlert], _ marketData: [String: CoinMarketData]) {
        persistence.context.perform { [weak self] in
            let batchSize = 50
            var offset = 0

            while offset < priceAlerts.count {
                let batchPriceAlerts = Array(priceAlerts[offset..<min(offset + batchSize, priceAlerts.count)])
                for priceAlert in batchPriceAlerts {
                    if let marketData = marketData[priceAlert.id] {
                        priceAlert.currentPrice = marketData.currentPrice ?? .zero
                        priceAlert.priceChange = marketData.priceChange ?? .zero
                    }
                }
                offset += batchSize
            }
            self?.persistence.save()
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
