//
//  TideCondition.swift
//  tides
//
//  Created by Zach Maillard on 9/23/26.
//
import Foundation

enum Quality: String, CustomStringConvertible {
    case preliminary
    case verified
    
    var description: String {
        switch self {
        case .preliminary:
            return "Preliminary"
        case .verified:
            return "Verified"
        }
    }
}
 

struct TideCondition: TimeSeries, Equatable, Identifiable {
    let id = UUID()
    let timeGMT: Date
    let localTimeZoneDisplay: String
    let value: Decimal
    let quality: Quality
    
    let timeZoneLocal: TimeZone
    
}

