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
    
    @Published var coins: [Coin] = []
    @Published var currentPage = 1
    @Published var errorMessage: String?
    @Published var showErrorAlert = false
    @Published var isLoading = false
    
    private let service: CoinScannerService
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
        isLoading = true
        service.getCoins(at: page)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.errorDescription
                    self?.showErrorAlert = true
                case .finished:
                    self?.currentPage = page
                }
            }, receiveValue: { [weak self] coins in
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
            isLoading = true
            service.searchCoins(by: query)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    switch completion {
                    case .failure(let error):
                        self?.errorMessage = error.errorDescription
                        self?.showErrorAlert = true
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] coinSearchResult in
                    self?.coins = coinSearchResult.coins
                })
                .store(in: &cancellables)
        }
    }
}
