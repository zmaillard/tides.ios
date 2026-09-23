//
//  TidePredictionTests.swift
//  TidesTests
//

import Testing
import Foundation
@testable import tides

struct TidePredictionTests {

    @Test("TideStage description for high")
    func highStageDescription() {
        #expect(TideStage.high.description == "High")
    }

    @Test("TideStage description for low")
    func lowStageDescription() {
        #expect(TideStage.low.description == "Low")
    }

    @Test("timeDisplayLocalTime formats date using the prediction's local timezone")
    func timeDisplayLocalTimeFormatsCorrectly() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "GMT")!
        let date = try #require(calendar.date(from: DateComponents(year: 2026, month: 9, day: 22, hour: 14, minute: 30)))

        let localTimeZone = try #require(TimeZone(secondsFromGMT: -8 * 3600))
        let prediction = TidePrediction(
            timeGMT: date,
            localTimeZoneDisplay: "PST",
            value: 1.5,
            stage: .high,
            timeZoneLocal: localTimeZone
        )

        let display = prediction.timeDisplayLocalTime(dateFormat: "yyyy-MM-dd HH:mm")
        #expect(display == "2026-09-22 06:30")
    }

    @Test("Two predictions with identical fields are not equal due to distinct UUIDs")
    func predictionsWithSameFieldsAreNotEqual() {
        let date = Date()
        let timeZone = TimeZone(secondsFromGMT: 0)!

        let first = TidePrediction(timeGMT: date, localTimeZoneDisplay: "GMT", value: 1.0, stage: .high, timeZoneLocal: timeZone)
        let second = TidePrediction(timeGMT: date, localTimeZoneDisplay: "GMT", value: 1.0, stage: .high, timeZoneLocal: timeZone)

        #expect(first != second)
        #expect(first.id != second.id)
    }
}
