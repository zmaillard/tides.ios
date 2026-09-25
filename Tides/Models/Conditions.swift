//
//  Conditions.swift
//  tides
//
//  Created by Zach Maillard on 9/23/26.
//

import Foundation

struct ConditionResult: Equatable, Codable  {
    let data: [Condition]
    
    enum CodingKeys: String, CodingKey {
        case data
    }
    
}

struct Condition: Equatable, Codable  {
    let t: String
    let v: String
    let s: String
    let f: String
    let q: String

    enum CodingKeys: String, CodingKey {
        case t
        case v
        case s
        case f
        case q
    }
    
    func toDomain(station: Station) -> TideCondition? {
        let localTimeDateFormatter = DateFormatter()
        localTimeDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        localTimeDateFormatter.timeZone =  TimeZone(abbreviation: "GMT")
        
        let date = localTimeDateFormatter.date(from: self.t)
        
        
        var readingQuality:Quality?
        if self.q.uppercased() == "P" {
            readingQuality = Quality.preliminary
        } else if self.q.uppercased() == "V" {
            readingQuality = Quality.verified
        }
        
        let localOffset: Int = station.observeDST ? station.timeZoneOffset + 1 : station.timeZoneOffset
        let targetTz = TimeZone(secondsFromGMT: 60 * 60 * localOffset)

        if let quality = readingQuality, let value = Decimal(string: self.v), let date = date, let localTime = targetTz  {
            return TideCondition(timeGMT: date, localTimeZoneDisplay: station.timeZone, value: value, quality: quality, timeZoneLocal: localTime)
        }
        
        return nil
    }
}
