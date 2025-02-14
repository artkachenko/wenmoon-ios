//
//  CoinMarketsViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 13.02.25.
//

import Foundation

final class CoinMarketsViewModel: BaseViewModel {
    // MARK: - Properties
    @Published private(set) var tickers: [CoinDetails.Ticker] = []
    
    @Published var searchText: String = ""
    
    var searchedTickers: [CoinDetails.Ticker] {
        let sortedTickers = tickers.sorted { ($0.convertedVolume ?? .zero) > ($1.convertedVolume ?? .zero) }
        if searchText.isEmpty {
            return sortedTickers
        } else {
            return sortedTickers.filter {
                $0.market.name?.localizedCaseInsensitiveContains(searchText) ?? false ||
                $0.market.identifier?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    // MARK: - Initializers
    init(tickers: [CoinDetails.Ticker]) {
        self.tickers = tickers
        super.init()
    }
}
