//
//  Optional+Extensions.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 07.11.24.
//

import Foundation

extension Optional where Wrapped == Double {
    func formattedOrNone(shouldShowPrefix: Bool = false) -> String {
        if let value = self {
            return "\(value.formatValue(shouldShowPrefix: shouldShowPrefix))"
        } else {
            return "-"
        }
    }
}

extension Optional where Wrapped == Int64 {
    func formattedOrNone() -> String {
        if let value = self {
            return String(format: "%lld", value)
        } else {
            return "-"
        }
    }
}
