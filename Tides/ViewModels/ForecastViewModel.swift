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
    var state: LoadingState<[Prediction]> = .idle
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
            let predictionResult =  try await service.getCurrentForecast(station: station.id)
            self.state = .loaded(predictionResult.predictions)
        } catch let error as APIError{
            self.state = .error(error.errorDescription ?? "unknown error")
        } catch {
            self.state = .error("unknown error")
        }
    }
    
}
