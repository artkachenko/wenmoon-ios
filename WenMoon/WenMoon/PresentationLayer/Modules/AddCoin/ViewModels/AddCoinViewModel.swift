//
//  AddCoinViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation

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

    @MainActor
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

    @MainActor
    func fetchCoinsOnNextPage() {
        fetchCoins(at: currentPage + 1)
    }

    @MainActor
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
                    let coinSearchResult = try await coinScannerService.searchCoins(by: query)
                    let coins = coinSearchResult.coins
                    searchCoinsCache[query] = coins
                    self.coins = coins

                    let coinIDs = coins.map { $0.id }
                    await fetchMarketData(for: coinIDs)
                } catch {
                    setErrorMessage(error)
                }
                isLoading = false
            }
        }
    }

    private func fetchMarketData(for coinIDs: [String]) async {
        do {
            isLoading = true
            let getMarketData = try await coinScannerService.getMarketData(for: coinIDs)
            marketData.merge(getMarketData, uniquingKeysWith: { $1 })
        } catch {
            setErrorMessage(error)
        }
        isLoading = false
    }
}
