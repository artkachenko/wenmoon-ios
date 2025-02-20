//
//  CryptoCompareViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 05.12.24.
//

import Foundation

final class CryptoCompareViewModel: BaseViewModel {
    // MARK: - Properties
    private let coinScannerService: CoinScannerService
    
    // MARK: - Initializers
    convenience init() {
        self.init(coinScannerService: CoinScannerServiceImpl())
    }
    
    init(coinScannerService: CoinScannerService) {
        self.coinScannerService = coinScannerService
        super.init()
    }
    
    // MARK: - Internal Methods
    func updateCoinIfNeeded(_ coin: Coin) async -> Coin {
        var updatedCoin = coin
        if (coin.ath == nil) || (coin.circulatingSupply == nil) {
            guard let coinDetails = try? await coinScannerService.getCoinDetails(for: coin.id) else {
                return updatedCoin
            }
            updatedCoin.ath = coinDetails.marketData.ath
            updatedCoin.circulatingSupply = coinDetails.marketData.circulatingSupply
        }
        return updatedCoin
    }
    
    func calculatePrice(for coinA: Coin?, coinB: Coin?, option: PriceOption) -> Double? {
        guard let coinA, let coinB else { return nil }
        
        switch option {
        case .now:
            guard let marketCap = coinB.marketCap, let supply = coinA.circulatingSupply else { return nil }
            return marketCap / supply
        case .ath:
            guard
                let bATH = coinB.ath,
                let bSupply = coinB.circulatingSupply,
                let aSupply = coinA.circulatingSupply
            else {
                return nil
            }
            
            return (bATH * bSupply) / aSupply
        }
    }
    
    func calculateMultiplier(for coinA: Coin?, coinB: Coin?, option: PriceOption) -> Double? {
        let hypotheticalPrice = calculatePrice(
            for: coinA,
            coinB: coinB,
            option: option
        )
        
        guard
            let coinA,
            let hypotheticalPrice,
            let currentPrice = coinA.currentPrice
        else {
            return nil
        }
        
        return hypotheticalPrice / currentPrice
    }
    
    func isPositiveMultiplier(_ multiplier: Double) -> Bool? {
        guard multiplier.isFinite else { return nil }
        
        let tolerance = 0.001
        let isCloseToZero = abs(multiplier) <= tolerance
        let isCloseToOne = abs(multiplier - 1) <= tolerance
        
        guard !isCloseToZero && !isCloseToOne else { return nil }
        
        return multiplier > 1
    }
}

enum PriceOption: String, CaseIterable {
    case now = "NOW"
    case ath = "ATH"
}
