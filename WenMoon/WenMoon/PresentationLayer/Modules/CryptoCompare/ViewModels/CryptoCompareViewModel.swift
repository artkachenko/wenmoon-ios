//
//  CryptoCompareViewModel.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 05.12.24.
//

import Foundation

final class CryptoCompareViewModel: BaseViewModel {
    // MARK: - Internal Methods
    func calculatePrice(for coinToBeCompared: Coin, coinToCompareWith: Coin, option: PriceOption) -> Double? {
        switch option {
        case .now:
            guard let marketCap = coinToCompareWith.marketCap, let supply = coinToBeCompared.circulatingSupply else { return nil }
            return marketCap / supply
        case .ath:
            guard
                let coinToCompareWithATH = coinToCompareWith.ath,
                let coinToCompareWithSupply = coinToCompareWith.circulatingSupply,
                let coinToBeComparedSupply = coinToBeCompared.circulatingSupply
            else {
                return nil
            }
            return (coinToCompareWithATH * coinToCompareWithSupply) / coinToBeComparedSupply
        }
    }
    
    func calculateMultiplier(for coinToBeCompared: Coin, coinToCompareWith: Coin, option: PriceOption) -> Double? {
        guard let hypotheticalPrice = calculatePrice(for: coinToBeCompared, coinToCompareWith: coinToCompareWith, option: option),
              let currentPrice = coinToBeCompared.currentPrice else {
            return nil
        }
        return hypotheticalPrice / currentPrice
    }
    
    func isPositiveMultiplier(_ multiplier: Double) -> Bool {
        multiplier >= 1
    }
}

enum PriceOption: String, CaseIterable {
    case now = "NOW"
    case ath = "ATH"
}
