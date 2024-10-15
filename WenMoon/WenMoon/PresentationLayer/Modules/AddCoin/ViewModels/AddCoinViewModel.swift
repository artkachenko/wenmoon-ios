//
//  AddCoinViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 22.04.23.
//

import Foundation
import Combine

final class AddCoinViewModel: BaseViewModel {
    
    // MARK: - Properties
    
    @Published private(set) var coins: [Coin] = []
    @Published private(set) var currentPage = 1
    
    private let coinScannerService: CoinScannerService
    
    private var coinsCache: [Int: [Coin]] = [:]
    private var searchCoinsCache: [String: [Coin]] = [:]
    private var searchQuerySubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    convenience init() {
        self.init(coinScannerService: CoinScannerServiceImpl())
    }
    
    init(coinScannerService: CoinScannerService) {
        self.coinScannerService = coinScannerService
        super.init()
        
        searchQuerySubject
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] query in
                Task {
                    await self?.searchCoins(for: query)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Methods
    
    func fetchCoins(at page: Int = 1) async {
        if let cachedCoins = coinsCache[page] {
            if page > 1 {
                coins += cachedCoins
            } else {
                coins = cachedCoins
            }
            currentPage = page
            return
        }
        
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
    
    func fetchCoinsOnNextPage() async {
        await fetchCoins(at: currentPage + 1)
    }
    
    func handleSearchInput(_ query: String) async {
        guard !query.isEmpty else {
            await fetchCoins()
            return
        }
        searchQuerySubject.send(query)
    }
    
    func searchCoins(for query: String) async {
        if let cachedCoins = searchCoinsCache[query] {
            coins = cachedCoins
            return
        }
        
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
