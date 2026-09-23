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
        var result: Result<PredictionResult, Error>

        func getCurrentForecast(station: String) async throws -> PredictionResult {
            switch result {
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
        let prediction = Prediction(id: future, v: "1.5", type: "H")
        let service = MockTideService(result: .success(PredictionResult(predictions: [prediction])))
        let viewModel = ForecastViewModel(service: service)
        let station = makeStation()

        #expect(viewModel.state == .idle)

        await viewModel.fetch(for: station)

        guard case .loaded(let predictions) = viewModel.state else {
            Issue.record("Expected loaded state, got \(viewModel.state)")
            return
        }
        #expect(predictions.count == 1)
        #expect(predictions.first?.stage == .high)
        #expect(viewModel.title == "Forecast for \(station.name)")
    }

    @Test("Failed fetch transitions to error state with the API error's description")
    func failedFetchTransitionsToError() async {
        let service = MockTideService(result: .failure(APIError.invalidResponse))
        let viewModel = ForecastViewModel(service: service)

        await viewModel.fetch(for: makeStation())

        #expect(viewModel.state == .error("Invalid response from server"))
    }

    @Test("Failed fetch with a non-APIError falls back to unknown error message")
    func failedFetchWithUnknownErrorFallsBack() async {
        struct SomeError: Error {}
        let service = MockTideService(result: .failure(SomeError()))
        let viewModel = ForecastViewModel(service: service)

        await viewModel.fetch(for: makeStation())

        #expect(viewModel.state == .error("unknown error"))
    }

    @Test("Predictions that fail to parse are filtered out of the loaded result")
    func unparsablePredictionsAreFilteredOut() async {
        let future = predictionTimestamp(Date().addingTimeInterval(3600))
        let good = Prediction(id: future, v: "1.5", type: "H")
        let bad = Prediction(id: "not-a-date", v: "1.5", type: "H")
        let service = MockTideService(result: .success(PredictionResult(predictions: [good, bad])))
        let viewModel = ForecastViewModel(service: service)

        await viewModel.fetch(for: makeStation())

        guard case .loaded(let predictions) = viewModel.state else {
            Issue.record("Expected loaded state, got \(viewModel.state)")
            return
        }
        #expect(predictions.count == 1)
    }

    @Test("Fetch is a no-op while already loading without an error")
    func fetchIsNoOpWhileLoadingWithoutError() async {
        let service = MockTideService(result: .success(PredictionResult(predictions: [])))
        let viewModel = ForecastViewModel(service: service)
        viewModel.state = .loading

        await viewModel.fetch(for: makeStation())

        #expect(viewModel.state == .loading)
        #expect(viewModel.title.isEmpty)
    }

    @Test("Fetch retries when current state is an error")
    func fetchRetriesFromErrorState() async {
        let future = predictionTimestamp(Date().addingTimeInterval(3600))
        let prediction = Prediction(id: future, v: "1.5", type: "H")
        let service = MockTideService(result: .success(PredictionResult(predictions: [prediction])))
        let viewModel = ForecastViewModel(service: service)
        viewModel.state = .error("previous failure")

        await viewModel.fetch(for: makeStation())

        guard case .loaded(let predictions) = viewModel.state else {
            Issue.record("Expected loaded state, got \(viewModel.state)")
            return
        }
        #expect(predictions.count == 1)
    }

    @Test("Predictions in the past are filtered out of the loaded result")
    func pastPredictionsAreFilteredOut() async {
        let past = predictionTimestamp(Date().addingTimeInterval(-3600))
        let future = predictionTimestamp(Date().addingTimeInterval(3600))
        let pastPrediction = Prediction(id: past, v: "1.5", type: "H")
        let futurePrediction = Prediction(id: future, v: "1.5", type: "L")
        let service = MockTideService(result: .success(PredictionResult(predictions: [pastPrediction, futurePrediction])))
        let viewModel = ForecastViewModel(service: service)

        await viewModel.fetch(for: makeStation())

        guard case .loaded(let predictions) = viewModel.state else {
            Issue.record("Expected loaded state, got \(viewModel.state)")
            return
        }
        #expect(predictions.count == 1)
        #expect(predictions.first?.stage == .low)
    }
}
