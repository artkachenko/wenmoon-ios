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
    func formatValue(minimumFractionDigits: Int = 0, maximumFractionDigits: Int = 2, shouldShowPrefix: Bool = false) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = minimumFractionDigits
        numberFormatter.maximumFractionDigits = maximumFractionDigits
        numberFormatter.numberStyle = .decimal
        numberFormatter.groupingSeparator = "."
        numberFormatter.decimalSeparator = ","
        if shouldShowPrefix {
            numberFormatter.positivePrefix = "+"
            numberFormatter.negativePrefix = "-"
        }
        return numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
}
