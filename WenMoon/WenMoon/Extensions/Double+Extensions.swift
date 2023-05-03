//
//  Double+Extensions.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 26.04.23.
//

import Foundation

extension Double {
    /// This extension adds a method to the Double type to format its value as a string with a specific number of decimal places, using commas as the decimal separator and periods as the grouping separator.
    /// It also allows for an optional positive or negative prefix, depending on whether the `shouldShowPrefix` parameter is set to true or false.
    func formatValue(minimumFractionDigits: Int = 2,
                     maximumFractionDigits: Int = 2,
                     shouldShowPrefix: Bool = false) -> String {
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


extension Double {
    /// This extension adds a property to the Double type to check if the value is negative.
    var isNegative: Bool {
        self < 0
    }
}

