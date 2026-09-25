//
//  ForecastViewModelTests.swift
//  TidesTests
//

import Testing
import Foundation
@testable import tides

@MainActor
struct ForecastViewModelTests {
    
    private struct MockTideService: TideService {
        var predictionResult: Result<PredictionResult, Error>
        var conditionResult: Result<ConditionResult, Error>
        
        func getCurrentForecast(station: String, units: Units) async throws -> PredictionResult {
            switch predictionResult {
            case .success(let value): return value
            case .failure(let error): throw error
            }
        }
        
        func getCurrentConditions(station: String, units: Units) async throws -> ConditionResult {
            switch conditionResult {
            case .success(let value): return value
            case .failure(let error): throw error
            }
        }
    }
    
    private func makeStation() -> Station {
        Station(
            timeZone: "GMT",
            name: "Test Station",
            isTidal: true,
            state: "CA",
            greatLakes: false,
            region: "Pacific",
            tideType: "Semidiurnal",
            id: "1234567",
            latitude: 0,
            longitude: 0,
            observeDST: false,
            timeZoneOffset: 0
        )
    }
    
    /// Formats a date the same way NOAA prediction timestamps arrive: "yyyy-MM-dd HH:mm" in GMT.
    private func predictionTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.timeZone = TimeZone(abbreviation: "GMT")
        return formatter.string(from: date)
    }
    
    @Test("Successful fetch transitions from idle to loading to loaded")
    func successfulFetchTransitionsToLoaded() async {
        let future = predictionTimestamp(Date().addingTimeInterval(3600))
        let prediction = Prediction(t: future, v: "1.5", type: "H")
        let condition = Condition(t: future, v: "1.0", s: "1.0", f: "1,1,1,1", q: "p" )
        let service = MockTideService(predictionResult: .success(PredictionResult(predictions: [prediction])), conditionResult: .success(ConditionResult(data: [condition])))
        let viewModel = ForecastViewModel(service: service)
        let station = makeStation()
        
        #expect(viewModel.state == .idle)
        
        await viewModel.fetch(for: station, units: .english)
        
        guard case .loaded(let results) = viewModel.state else {
            Issue.record("Expected loaded state, got \(viewModel.state)")
            return
        }
        #expect(results.predictions.count == 1)
        #expect(results.predictions.first?.stage == .high)
        #expect(viewModel.title == "Forecast for \(station.name)")
    }
    
    @Test("Failed fetch transitions to error state with the API error's description")
    func failedFetchTransitionsToError() async {
        let service = MockTideService(predictionResult: .failure(APIError.invalidResponse), conditionResult: .failure(APIError.invalidResponse))
        let viewModel = ForecastViewModel(service: service)
        
        await viewModel.fetch(for: makeStation(), units: .english)
        
        #expect(viewModel.state == .error("Invalid response from server"))
    }
    
    @Test("Failed fetch with a non-APIError falls back to unknown error message")
    func failedFetchWithUnknownErrorFallsBack() async {
        struct SomeError: Error {}
        let service = MockTideService(predictionResult: .failure(SomeError()), conditionResult: .failure(SomeError()))
        let viewModel = ForecastViewModel(service: service)
        
        await viewModel.fetch(for: makeStation(), units: .english)
        
        #expect(viewModel.state == .error("unknown error"))
    }
    
     @Test("Predictions that fail to parse are filtered out of the loaded result")
    func unparsablePredictionsAreFilteredOut() async {
        let future = predictionTimestamp(Date().addingTimeInterval(3600))
        let good = Prediction(t: future, v: "1.5", type: "H")
        let bad = Prediction(t: "not-a-date", v: "1.5", type: "H")
        let service = MockTideService(predictionResult: .success(PredictionResult(predictions: [good, bad])), conditionResult: .success(ConditionResult(data: [])))
        let viewModel = ForecastViewModel(service: service)
        
        await viewModel.fetch(for: makeStation(), units: .english)
        
        guard case .loaded(let results) = viewModel.state else {
            Issue.record("Expected loaded state, got \(viewModel.state)")
            return
        }
        #expect(results.predictions.count == 1)
    }
    
    @Test("Fetch is a no-op while already loading without an error")
    func fetchIsNoOpWhileLoadingWithoutError() async {
        let service = MockTideService(predictionResult: .success(PredictionResult(predictions: [])),conditionResult:  .success(ConditionResult(data: [])))
        let viewModel = ForecastViewModel(service: service)
        viewModel.state = .loading
        
        await viewModel.fetch(for: makeStation(), units:.english)
        
        #expect(viewModel.state == .loading)
        #expect(viewModel.title.isEmpty)
    }
    
    @Test("Fetch retries when current state is an error")
    func fetchRetriesFromErrorState() async {
        let future = predictionTimestamp(Date().addingTimeInterval(3600))
        let prediction = Prediction(t: future, v: "1.5", type: "H")
        let service = MockTideService(predictionResult: .success(PredictionResult(predictions: [prediction])), conditionResult:  .success(ConditionResult(data: [])))
        let viewModel = ForecastViewModel(service: service)
        viewModel.state = .error("previous failure")
        
        await viewModel.fetch(for: makeStation(), units: .english)
        
        guard case .loaded(let results) = viewModel.state else {
            Issue.record("Expected loaded state, got \(viewModel.state)")
            return
        }
        #expect(results.predictions.count == 1)
    }
    
    @Test("Predictions in the past are filtered out of the loaded result")
    func pastPredictionsAreFilteredOut() async {
        let past = predictionTimestamp(Date().addingTimeInterval(-3600))
        let future = predictionTimestamp(Date().addingTimeInterval(3600))
        let pastPrediction = Prediction(t: past, v: "1.5", type: "H")
        let futurePrediction = Prediction(t: future, v: "1.5", type: "L")
        let service = MockTideService(predictionResult: .success(PredictionResult(predictions: [pastPrediction, futurePrediction])), conditionResult:  .success(ConditionResult(data: [])))
        let viewModel = ForecastViewModel(service: service)
        
        await viewModel.fetch(for: makeStation(), units: .english)
        
        guard case .loaded(let results) = viewModel.state else {
            Issue.record("Expected loaded state, got \(viewModel.state)")
            return
        }
        #expect(results.predictions.count == 1)
        #expect(results.predictions.first?.stage == .low)
    }
}
