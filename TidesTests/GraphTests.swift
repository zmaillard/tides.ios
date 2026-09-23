//
//  GraphTests.swift
//  TidesTests
//

import Testing
import Foundation
import ViewInspector
@testable import tides

@MainActor
struct GraphTests {

    private func makePrediction(minutesFromNow: Double, value: Decimal, stage: TideStage = .high) -> TidePrediction {
        let timeZone = TimeZone(secondsFromGMT: 0)!
        return TidePrediction(
            timeGMT: Date().addingTimeInterval(minutesFromNow * 60),
            localTimeZoneDisplay: "GMT",
            value: value,
            stage: stage,
            timeZoneLocal: timeZone
        )
    }

    @Test("Renders successfully with multiple predictions")
    func rendersWithMultiplePredictions() async throws {
        let predictions = [
            makePrediction(minutesFromNow: 0, value: 1.0, stage: .low),
            makePrediction(minutesFromNow: 60, value: 2.5, stage: .high),
            makePrediction(minutesFromNow: 120, value: 1.2, stage: .low)
        ]
        let sut = Graph(predictions: predictions)

        try await ViewHosting.host(sut) {
            #expect(sut.predictions.count == 3)
        }
    }

    @Test("Renders successfully with a single prediction")
    func rendersWithSinglePrediction() async throws {
        let predictions = [makePrediction(minutesFromNow: 0, value: 1.0)]
        let sut = Graph(predictions: predictions)

        try await ViewHosting.host(sut) {
            #expect(sut.predictions.count == 1)
        }
    }

    @Test("Renders successfully with no predictions")
    func rendersWithNoPredictions() async throws {
        let sut = Graph(predictions: [])

        try await ViewHosting.host(sut) {
            #expect(sut.predictions.isEmpty)
        }
    }
}
