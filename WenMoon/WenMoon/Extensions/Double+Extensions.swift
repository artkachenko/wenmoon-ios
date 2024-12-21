//
//  Double+Extensions.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 26.04.23.
//

import Foundation

extension Double {
    var isNegative: Bool {
        self < 0
    }
}

extension Double {
    func formattedWithAbbreviation(suffix: String = "") -> String {
        let number = abs(self)
        let sign = self < 0 ? "-" : suffix
        let format = "%.2f"
        
        switch number {
        case 1_000_000_000_000...:
            return "\(sign)\(String(format: format, number / 1_000_000_000_000)) T"
        case 1_000_000_000...:
            return "\(sign)\(String(format: format, number / 1_000_000_000)) B"
        case 1_000_000...:
            return "\(sign)\(String(format: format, number / 1_000_000)) M"
        case 1_000...:
            return "\(sign)\(String(format: format, number / 1_000)) K"
        default:
            return "\(sign)\(String(format: format, number))"
        }
    }
}

extension Double {
    func formattedAsCurrency(currencySymbol: String = "$", includePlusSign: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = currencySymbol
        
        guard !isNegative else {
            formatter.maximumFractionDigits = 2
            return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
        }
        
        if self < 0.01 {
            formatter.maximumFractionDigits = 6
        } else if self < 1 {
            formatter.maximumFractionDigits = 4
        } else {
            formatter.maximumFractionDigits = 2
        }
        
        let formattedValue = formatter.string(from: NSNumber(value: self)) ?? "\(self)"
        if includePlusSign && self > 0 {
            return "+\(formattedValue)"
        }
        return formattedValue
    }
}

extension Double {
    func formattedAsPercentage(includePlusSign: Bool = true) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .percent
        formatter.maximumFractionDigits = 2
        formatter.positiveSuffix = " %"
        formatter.negativeSuffix = " %"
        
        let formattedValue = formatter.string(from: NSNumber(value: self / 100)) ?? "\(self)%"
        if includePlusSign && self > 0 {
            return "+\(formattedValue)"
        }
        return formattedValue
    }
}

extension Double {
    func formattedAsMultiplier() -> String {
        "(\(String(format: "%.2f", self))x)"
    }
}

extension Double {
    func formattedAsQuantity(includeMinusSign: Bool = false) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true

        if self == floor(self) {
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
        } else {
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 6
        }
        
        let formattedValue = formatter.string(from: NSNumber(value: self)) ?? "\(self)"
        if includeMinusSign {
            return "-\(formattedValue)"
        }
        return formattedValue
    }
}
