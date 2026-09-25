//
//  Predictions.swift
//  tides
//
//  Created by Zach Maillard on 9/18/26.
//
import Foundation

struct PredictionResult : Codable {
    let predictions: [Prediction]
    
}

struct Prediction : Equatable, Codable {
    let t: String
    let v: String
    let type: String // H or L
    
    
    enum CodingKeys: String, CodingKey {
        case t
        case v
        case type
    }
    
    
    func toDomain(station: Station) -> TidePrediction? {
        let localTimeDateFormatter = DateFormatter()
        localTimeDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        localTimeDateFormatter.timeZone =  TimeZone(abbreviation: "GMT")
        
        let date = localTimeDateFormatter.date(from: self.t)
        
        
        var tideStage:TideStage?
        if self.type.uppercased() == "H" {
            tideStage = TideStage.high
        } else if self.type.uppercased() == "L" {
            tideStage = TideStage.low
        }
        
        let localOffset: Int = station.observeDST ? station.timeZoneOffset + 1 : station.timeZoneOffset
        let targetTz = TimeZone(secondsFromGMT: 60 * 60 * localOffset)

        if let tideStage = tideStage, let value = Decimal(string: self.v), let date = date, let localTime = targetTz  {
            return TidePrediction(timeGMT: date, localTimeZoneDisplay: station.timeZone, value: value, stage: tideStage, timeZoneLocal: localTime)
        }
        
        return nil
    }
    
}
