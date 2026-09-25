//
//  TideService.swift
//  tides
//
//  Created by Zach Maillard on 9/18/26.
//
enum RequestType: String {
    case waterlevel
    case predictions
}

protocol TideService {
    func getCurrentForecast(station: String, units: Units) async throws -> PredictionResult
    func getCurrentConditions(station: String, units: Units) async throws -> ConditionResult
}
