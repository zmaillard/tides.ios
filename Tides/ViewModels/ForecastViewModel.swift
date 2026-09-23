//
//  ForecastViewModel.swift
//  tides
//
//  Created by Zach Maillard on 9/18/26.
//
import Foundation
import SwiftUI

@Observable
class ForecastViewModel {
    var state: LoadingState<[TidePrediction]> = .idle
    private let service: TideService
    
    var title: String = ""
    
    init(service: TideService = DefaultTideService()) {
        self.service = service
    }
    
    
    func fetch(for station: Station) async {
        guard !state.isLoading || state.error != nil else { return }
        self.state = .loading
        do {
            title = "Forecast for \(station.name)"
            
            let now = Date.now
            let predictionResult =  try await service.getCurrentForecast(station: station.id)
            let predDomain = predictionResult.predictions
                .map { $0.toDomain(station: station) }
                .filter{$0 != nil}
                .map{$0!}
                .filter{$0.timeGMT >= now}
            
            self.state = .loaded(predDomain)
        } catch let error as APIError{
            self.state = .error(error.errorDescription ?? "unknown error")
        } catch {
            self.state = .error("unknown error")
        }
    }
    
}
