//
//  AddPriceAlertViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation
import Combine

final class AddPriceAlertViewModel: ObservableObject {

    // MARK: - Properties

    @Published private(set) var coins: [Coin] = []
    @Published private(set) var marketData: [String: CoinMarketData] = [:]
    @Published private(set) var currentPage = 1
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading = false

    private let service: CoinScannerService
    private var coinsCache: [Int: [Coin]] = [:]
    private var searchCoinsCache: [String: [Coin]] = [:]
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializers

    convenience init() {
        self.init(service: CoinScannerServiceImpl())
    }

    init(service: CoinScannerService) {
        self.service = service
    }

    // MARK: - Methods

    func fetchCoins(at page: Int = 1) {
        if let cachedCoins = coinsCache[page] {
            if page > 1 {
                coins += cachedCoins
            } else {
                coins = cachedCoins
            }
            currentPage = page
            return
        }

        isLoading = true
        service.getCoins(at: page)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.errorDescription
                case .finished:
                    self?.currentPage = page
                }
            }, receiveValue: { [weak self] coins in
                self?.coinsCache[page] = coins
                if page > 1 {
                    self?.coins += coins
                } else {
                    self?.coins = coins
                }
            })
            .store(in: &cancellables)
    }

    func fetchCoinsOnNextPage() {
        fetchCoins(at: currentPage + 1)
    }

    func searchCoins(by query: String) {
        guard !query.isEmpty else {
            fetchCoins()
            return
        }
        if query.count % 3 == .zero {
            if let cachedCoins = searchCoinsCache[query] {
                coins = cachedCoins
                return
            }
            isLoading = true
            service.searchCoins(by: query)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    switch completion {
                    case .failure(let error):
                        self?.errorMessage = error.errorDescription
                    case .finished: break
                    }
                }, receiveValue: { [weak self] coinSearchResult in
                    let coins = coinSearchResult.coins
                    self?.searchCoinsCache[query] = coins
                    self?.coins = coins

                    let coinIDs = coins.map { $0.id }
                    self?.fetchMarketData(for: coinIDs)
                })
                .store(in: &cancellables)
        }
    }

    func fetchMarketData(for coinIDs: [String]) {
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
            })
            .store(in: &cancellables)
    }
}
