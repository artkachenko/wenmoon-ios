//
//  Date+Extensions.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 08.11.24.
//

import Foundation

extension Date {
    enum FormatType {
        case relative
        case dateOnly
        case timeOnly
        case dateAndTime
    }
    
    func formatted(as formatType: FormatType) -> String {
        let dateFormatter = DateFormatter()
        switch formatType {
        case .relative:
            return relativeTimeString()
        case .dateOnly:
            dateFormatter.dateFormat = "d MMM yyyy"
        case .timeOnly:
            dateFormatter.dateFormat = "HH:mm"
        case .dateAndTime:
            dateFormatter.dateFormat = "d MMM, HH:mm"
        }
        return dateFormatter.string(from: self)
    }
    
    private func relativeTimeString() -> String {
        let now = Date()
        let timeInterval = now.timeIntervalSince(self)
        
        guard timeInterval >= 0 else {
            return "In the future"
        }
        
        let seconds = Int(timeInterval)
        let minutes = seconds / 60
        let hours = minutes / 60
        let days = hours / 24
        let months = days / 30
        let years = days / 365
        
        switch seconds {
        case 0..<60:
            return "Just now"
        case 60..<3600:
            return "\(minutes)m ago"
        case 3600..<86400:
            return "\(hours)h ago"
        case 86400..<2592000:
            return "\(days)d ago"
        case 2592000..<31536000:
            return "\(months)mo ago"
        default:
            return "\(years) year ago"
        }
    }
}
