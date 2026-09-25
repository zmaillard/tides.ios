//
//  CurrentStageTests.swift
//  TidesTests
//

import Testing
import Foundation
import ViewInspector
@testable import tides

@MainActor
struct CurrentStageTests {

    private func makeCondition(value: Decimal = 1.5, quality: Quality = .verified) -> TideCondition {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "GMT")!
        let date = calendar.date(from: DateComponents(year: 2026, month: 9, day: 22, hour: 14, minute: 30))!
        let localTimeZone = TimeZone(secondsFromGMT: -8 * 3600)!

        return TideCondition(
            timeGMT: date,
            localTimeZoneDisplay: "PST",
            value: value,
            quality: quality,
            timeZoneLocal: localTimeZone
        )
    }

    @Test("Displays the 'Current Conditions' title")
    func displaysTitle() throws {
        let sut = CurrentStage(condition: makeCondition())

        let text = try sut.inspect().find(text: "Current Conditions")
        #expect(try text.string() == "Current Conditions")
    }

    @Test("Displays the formatted local time and timezone display")
    func displaysFormattedLocalTime() throws {
        let condition = makeCondition()
        let sut = CurrentStage(condition: condition)

        let expected = "\(condition.timeDisplayLocalTime(dateFormat: "yyyy-MM-dd HH:mm")) \(condition.localTimeZoneDisplay)"
        let text = try sut.inspect().find(text: expected)
        #expect(try text.string() == expected)
    }

    @Test("Displays value with 'meters' when Units is metric")
    func displaysMetersForMetricUnits() throws {
        UserDefaults.standard.set(Units.metric.rawValue, forKey: "Units")
        defer { UserDefaults.standard.removeObject(forKey: "Units") }

        let sut = CurrentStage(condition: makeCondition(value: 1.5))

        let text = try sut.inspect().find(text: "1.5 meters")
        #expect(try text.string() == "1.5 meters")
    }

    @Test("Displays value with 'feet' when Units is english")
    func displaysFeetForEnglishUnits() throws {
        UserDefaults.standard.set(Units.english.rawValue, forKey: "Units")
        defer { UserDefaults.standard.removeObject(forKey: "Units") }

        let sut = CurrentStage(condition: makeCondition(value: 1.5))

        let text = try sut.inspect().find(text: "1.5 feet")
        #expect(try text.string() == "1.5 feet")
    }
}
