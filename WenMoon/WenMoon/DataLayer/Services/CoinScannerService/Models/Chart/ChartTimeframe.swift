//
//  ChartTimeframe.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 14.11.24.
//

import Foundation

enum Timeframe: CaseIterable {
    case oneDay, oneWeek, oneMonth, yearToDate
    
    var value: String {
        switch self {
        case .oneDay: return "1"
        case .oneWeek: return "7"
        case .oneMonth: return "31"
        case .yearToDate: return "365"
        }
    }
    
    var displayValue: String {
        switch self {
        case .oneDay: return "1D"
        case .oneWeek: return "1W"
        case .oneMonth: return "1M"
        case .yearToDate: return "YTD"
        }
    }
}
