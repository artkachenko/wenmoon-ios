//
//  GlobalMarketData.swift
//  WenMoon
//
//  Created by Artur Tkachenko on 12.12.24.
//

import Foundation

struct GlobalMarketData: Codable {
    // MARK: - Properties
    let cpiPercentage: Double
    let nextCPIDate: Date
    let interestRatePercentage: Double
    let nextFOMCMeetingDate: Date
    
    // MARK: - Initializers
    init(
        cpiPercentage: Double,
        nextCPIDate: Date,
        interestRatePercentage: Double,
        nextFOMCMeetingDate: Date
    ) {
        self.cpiPercentage = cpiPercentage
        self.nextCPIDate = nextCPIDate
        self.interestRatePercentage = interestRatePercentage
        self.nextFOMCMeetingDate = nextFOMCMeetingDate
    }
    
    // MARK: - Codable
    private enum CodingKeys: String, CodingKey {
        case cpiPercentage, nextCPITimestamp, interestRatePercentage, nextFOMCMeetingTimestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let nextCPITimestamp = try container.decode(Int.self, forKey: .nextCPITimestamp)
        let nextFOMCMeetingTimestamp = try container.decode(Int.self, forKey: .nextFOMCMeetingTimestamp)
        cpiPercentage = try container.decode(Double.self, forKey: .cpiPercentage)
        nextCPIDate = Date(timeIntervalSince1970: TimeInterval(nextCPITimestamp))
        interestRatePercentage = try container.decode(Double.self, forKey: .interestRatePercentage)
        nextFOMCMeetingDate = Date(timeIntervalSince1970: TimeInterval(nextFOMCMeetingTimestamp))
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(cpiPercentage, forKey: .cpiPercentage)
        try container.encode(Int(nextCPIDate.timeIntervalSince1970), forKey: .nextCPITimestamp)
        try container.encode(interestRatePercentage, forKey: .interestRatePercentage)
        try container.encode(Int(nextFOMCMeetingDate.timeIntervalSince1970), forKey: .nextFOMCMeetingTimestamp)
    }
}
