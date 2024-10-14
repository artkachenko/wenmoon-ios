//
//  AddCoinViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

@MainActor
final class AddCoinViewModel: BaseViewModel {

    // MARK: - Properties

    @Published private(set) var coins: [Coin] = []
    @Published private(set) var marketData: [String: MarketData] = [:]
    @Published private(set) var currentPage = 1

    private let coinScannerService: CoinScannerService

    private var coinsCache: [Int: [Coin]] = [:]
    private var searchCoinsCache: [String: [Coin]] = [:]

    // MARK: - Initializers

    convenience init() {
        self.init(coinScannerService: CoinScannerServiceImpl())
    }

    init(coinScannerService: CoinScannerService) {
        self.coinScannerService = coinScannerService
        super.init()
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

        Task {
            do {
                isLoading = true
                let fetchedCoins = try await coinScannerService.getCoins(at: page)
                coinsCache[page] = fetchedCoins
                if page > 1 {
                    coins += fetchedCoins
                } else {
                    coins = fetchedCoins
                }
                currentPage = page
            } catch {
                setErrorMessage(error)
            }
            isLoading = false
        }
    }

    func fetchCoinsOnNextPage() {
        fetchCoins(at: currentPage + 1)
    }

    func searchCoins(by query: String) {
        guard !query.isEmpty else {
            fetchCoins()
            return
        }
        if query.count % 2 == .zero {
            if let cachedCoins = searchCoinsCache[query] {
                coins = cachedCoins
                return
            }

            Task {
                do {
                    isLoading = true
                    let coins = try await coinScannerService.searchCoins(by: query)
                    searchCoinsCache[query] = coins
                    self.coins = coins
                } catch {
                    setErrorMessage(error)
                }
                isLoading = false
            }
        }
    }
}
