//
//  TideService.swift
//  tides
//
//  Created by Zach Maillard on 9/18/26.
//
protocol TideService {
    func getCurrentForecast(station: String) async throws -> PredictionResult
}
