//
//  NextStageTests.swift
//  TidesTests
//

import Testing
import Foundation
import ViewInspector
@testable import tides

@MainActor
struct NextStageTests {

    private func makePrediction(stage: TideStage = .high, value: Decimal = 1.5) -> TidePrediction {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "GMT")!
        let date = calendar.date(from: DateComponents(year: 2026, month: 9, day: 22, hour: 14, minute: 30))!
        let localTimeZone = TimeZone(secondsFromGMT: -8 * 3600)!

        return TidePrediction(
            timeGMT: date,
            localTimeZoneDisplay: "PST",
            value: value,
            stage: stage,
            timeZoneLocal: localTimeZone
        )
    }

    @Test("Displays the stage description followed by 'Tide'")
    func displaysStageDescription() throws {
        let prediction = makePrediction(stage: .high)
        let sut = NextStage(prediction: prediction)

        let text = try sut.inspect().find(text: "High Tide")
        #expect(try text.string() == "High Tide")
    }

    @Test("Displays the low stage description")
    func displaysLowStageDescription() throws {
        let prediction = makePrediction(stage: .low)
        let sut = NextStage(prediction: prediction)

        let text = try sut.inspect().find(text: "Low Tide")
        #expect(try text.string() == "Low Tide")
    }

    @Test("Displays the formatted local time and timezone display")
    func displaysFormattedLocalTime() throws {
        let prediction = makePrediction()
        let sut = NextStage(prediction: prediction)

        let expected = "\(prediction.timeDisplayLocalTime(dateFormat: "yyyy-MM-dd HH:mm")) \(prediction.localTimeZoneDisplay)"
        let text = try sut.inspect().find(text: expected)
        #expect(try text.string() == expected)
    }

    @Test("Displays value with 'meters' when Units is metric")
    func displaysMetersForMetricUnits() throws {
        UserDefaults.standard.set(Units.metric.rawValue, forKey: "Units")
        defer { UserDefaults.standard.removeObject(forKey: "Units") }

        let prediction = makePrediction(value: 1.5)
        let sut = NextStage(prediction: prediction)

        let text = try sut.inspect().find(text: "1.5 meters")
        #expect(try text.string() == "1.5 meters")
    }

    @Test("Displays value with 'feet' when Units is english")
    func displaysFeetForEnglishUnits() throws {
        UserDefaults.standard.set(Units.english.rawValue, forKey: "Units")
        defer { UserDefaults.standard.removeObject(forKey: "Units") }

        let prediction = makePrediction(value: 1.5)
        let sut = NextStage(prediction: prediction)

        let text = try sut.inspect().find(text: "1.5 feet")
        #expect(try text.string() == "1.5 feet")
    }
}
