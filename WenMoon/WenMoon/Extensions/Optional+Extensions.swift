//
//  Optional+Extensions.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 07.11.24.
//

import Foundation

extension Optional where Wrapped == Int64 {
    func formattedOrNone() -> String {
        guard let value = self else {
            return "-"
        }
        return String(value)
    }
}

extension Optional where Wrapped == Double {
    func formattedWithAbbreviation(placeholder: String = "-", suffix: String = "") -> String {
        guard let value = self else {
            return placeholder
        }
        return value.formattedWithAbbreviation(suffix: suffix)
    }
}

extension Optional where Wrapped == Double {
    func formattedAsCurrency(currencySymbol: String = "$") -> String {
        guard let value = self else {
            return "-"
        }
        return value.formattedAsCurrency(currencySymbol: currencySymbol)
    }
}

extension Optional where Wrapped == Double {
    func formattedAsPercentage(includePlusSign: Bool = true) -> String {
        guard let value = self else {
            return "-"
        }
        return value.formattedAsPercentage(includePlusSign: includePlusSign)
    }
}
