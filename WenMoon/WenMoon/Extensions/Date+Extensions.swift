//
//  Date+Extensions.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 08.11.24.
//

import Foundation

extension Date {
    enum FormatType {
        case dateOnly
        case timeOnly
        case dateAndTime
    }
    
    func formatted(as formatType: FormatType) -> String {
        let dateFormatter = DateFormatter()
        switch formatType {
        case .dateOnly:
            dateFormatter.dateFormat = "d MMM yyyy"
        case .timeOnly:
            dateFormatter.dateFormat = "HH:mm"
        case .dateAndTime:
            dateFormatter.dateFormat = "d MMM, HH:mm"
        }
        return dateFormatter.string(from: self)
    }
}
