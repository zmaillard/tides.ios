//
//  Predictions.swift
//  tides
//
//  Created by Zach Maillard on 9/18/26.
//
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
}
