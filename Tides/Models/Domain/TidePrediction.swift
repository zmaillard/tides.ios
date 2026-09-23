//
//  TidePrediction.swift
//  tides
//
//  Created by Zach Maillard on 9/21/26.
//
import Foundation

enum TideStage: String, CustomStringConvertible {
    case high
    case low
    
    var description: String {
        switch self {
        case .high:
            return "High"
        case .low:
            return "Low"
        }
    }
}

struct TidePrediction: Equatable, Identifiable {
    let id = UUID()
    let timeGMT: Date
    let localTimeZoneDisplay: String
    let value: Decimal
    let stage: TideStage
    
    let timeZoneLocal: TimeZone
    
    
    func timeDisplayLocalTime(dateFormat: String) -> String {
        let format = DateFormatter()
        format.timeZone = self.timeZoneLocal
         
        format.dateFormat = dateFormat
         
        return format.string(from: self.timeGMT)
    }
}

