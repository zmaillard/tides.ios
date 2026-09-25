//
//  ForecastViewModel.swift
//  tides
//
//  Created by Zach Maillard on 9/18/26.
//
import Foundation
import SwiftUI

struct CurrentForecast: Equatable {
    let predictions: [TidePrediction]
    let currentCondition: TideCondition?
}

@Observable
class ForecastViewModel {
    var state: LoadingState<CurrentForecast> = .idle
    private let service: TideService
    
    var title: String = ""
    
    init(service: TideService = DefaultTideService()) {
        self.service = service
    }
    
    
    func fetch(for station: Station, units: Units) async {
        guard !state.isLoading || state.error != nil else { return }
        self.state = .loading
        do {
            title = "Forecast for \(station.name)"
            
            let now = Date.now
            let predictionResult =  try await service.getCurrentForecast(station: station.id, units: units)
            let predDomain = predictionResult.predictions
                .map { $0.toDomain(station: station) }
                .filter{$0 != nil}
                .map{$0!}
                .filter{$0.timeGMT >= now}
            
            let currentCondition =  try await service.getCurrentConditions(station: station.id, units: units)
            if let latest = currentCondition.data.first {
                self.state = .loaded(CurrentForecast(predictions: predDomain, currentCondition: latest.toDomain(station: station)))

            } else {
                self.state = .loaded(CurrentForecast(predictions: predDomain, currentCondition: nil))
            }
            
        } catch let error as APIError{
            self.state = .error(error.errorDescription ?? "unknown error")
        } catch {
            self.state = .error("unknown error")
        }
    }
    
}
