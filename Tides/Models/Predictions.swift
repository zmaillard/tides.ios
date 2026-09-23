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

struct Prediction : Identifiable, Equatable, Codable {
    let id: String
    let v: String
    let type: String // H or L
    
    
    enum CodingKeys: String, CodingKey {
        case id = "t"
        case v
        case type
    }
    
    
    func toDomain(station: Station) -> TidePrediction? {
        let localTimeDateFormatter = DateFormatter()
        localTimeDateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        localTimeDateFormatter.timeZone =  TimeZone(abbreviation: "GMT")
        
        let date = localTimeDateFormatter.date(from: self.id)
        
        
        var tideStage:TideStage?
        if self.type.uppercased() == "H" {
            tideStage = TideStage.high
        } else if self.type.uppercased() == "L" {
            tideStage = TideStage.low
        }
        
        if let tideStage = tideStage, let value = Decimal(string: self.v), let date = date  {
            return TidePrediction(time: date, value: value, stage: tideStage)
        }
        
        return nil
    }
}
