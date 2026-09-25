//
//  ConditionTests.swift
//  TidesTests
//

import Testing
import Foundation
@testable import tides

struct ConditionTests {

    private func makeStation(observeDST: Bool = false, timeZoneOffset: Int = -8, timeZone: String = "PST") -> Station {
        Station(
            timeZone: timeZone,
            name: "Test Station",
            isTidal: true,
            state: "CA",
            greatLakes: false,
            region: "West Coast",
            tideType: "Semidiurnal",
            id: "1234567",
            latitude: 37.0,
            longitude: -122.0,
            observeDST: observeDST,
            timeZoneOffset: timeZoneOffset
        )
    }

    @Test("Uppercase P maps to preliminary quality")
    func uppercasePMapsToPreliminary() {
        let condition = Condition(t: "2026-09-22 06:00", v: "1.5", s: "0.1", f: "1,1,1,1", q: "P")
        let domain = condition.toDomain(station: makeStation())
        #expect(domain?.quality == .preliminary)
    }

    @Test("Lowercase p maps to preliminary quality")
    func lowercasePMapsToPreliminary() {
        let condition = Condition(t: "2026-09-22 06:00", v: "1.5", s: "0.1", f: "1,1,1,1", q: "p")
        let domain = condition.toDomain(station: makeStation())
        #expect(domain?.quality == .preliminary)
    }

    @Test("Uppercase V maps to verified quality")
    func uppercaseVMapsToVerified() {
        let condition = Condition(t: "2026-09-22 06:00", v: "1.5", s: "0.1", f: "1,1,1,1", q: "V")
        let domain = condition.toDomain(station: makeStation())
        #expect(domain?.quality == .verified)
    }

    @Test("Lowercase v maps to verified quality")
    func lowercaseVMapsToVerified() {
        let condition = Condition(t: "2026-09-22 06:00", v: "1.5", s: "0.1", f: "1,1,1,1", q: "v")
        let domain = condition.toDomain(station: makeStation())
        #expect(domain?.quality == .verified)
    }

    @Test("Unknown quality code returns nil")
    func unknownQualityCodeReturnsNil() {
        let condition = Condition(t: "2026-09-22 06:00", v: "1.5", s: "0.1", f: "1,1,1,1", q: "X")
        #expect(condition.toDomain(station: makeStation()) == nil)
    }

    @Test("Malformed date string returns nil")
    func malformedDateReturnsNil() {
        let condition = Condition(t: "not-a-date", v: "1.5", s: "0.1", f: "1,1,1,1", q: "P")
        #expect(condition.toDomain(station: makeStation()) == nil)
    }

    @Test("Non-numeric value returns nil")
    func nonNumericValueReturnsNil() {
        let condition = Condition(t: "2026-09-22 06:00", v: "abc", s: "0.1", f: "1,1,1,1", q: "P")
        #expect(condition.toDomain(station: makeStation()) == nil)
    }

    @Test("Valid GMT date string parses to expected date components")
    func validDateParsesCorrectly() throws {
        let condition = Condition(t: "2026-09-22 06:30", v: "1.5", s: "0.1", f: "1,1,1,1", q: "P")
        let domain = try #require(condition.toDomain(station: makeStation()))

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(abbreviation: "GMT")!
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: domain.timeGMT)

        #expect(components.year == 2026)
        #expect(components.month == 9)
        #expect(components.day == 22)
        #expect(components.hour == 6)
        #expect(components.minute == 30)
    }

    @Test("Non-DST station keeps configured timezone offset")
    func nonDSTStationKeepsOffset() throws {
        let station = makeStation(observeDST: false, timeZoneOffset: -8)
        let condition = Condition(t: "2026-09-22 06:00", v: "1.5", s: "0.1", f: "1,1,1,1", q: "V")
        let domain = try #require(condition.toDomain(station: station))

        #expect(domain.timeZoneLocal.secondsFromGMT() == -8 * 3600)
    }

    @Test("DST station applies one hour offset adjustment")
    func dstStationAppliesOneHourAdjustment() throws {
        let station = makeStation(observeDST: true, timeZoneOffset: -8)
        let condition = Condition(t: "2026-09-22 06:00", v: "1.5", s: "0.1", f: "1,1,1,1", q: "V")
        let domain = try #require(condition.toDomain(station: station))

        #expect(domain.timeZoneLocal.secondsFromGMT() == -7 * 3600)
    }

    @Test("localTimeZoneDisplay matches station timezone label")
    func localTimeZoneDisplayMatchesStation() throws {
        let station = makeStation(timeZone: "America/Los_Angeles")
        let condition = Condition(t: "2026-09-22 06:00", v: "1.5", s: "0.1", f: "1,1,1,1", q: "V")
        let domain = try #require(condition.toDomain(station: station))

        #expect(domain.localTimeZoneDisplay == "America/Los_Angeles")
    }

    @Test("Condition decodes from expected NOAA water_level keys")
    func conditionDecodesFromJSON() throws {
        let json = """
        { "t": "2026-09-22 06:00", "v": "1.5", "s": "0.1", "f": "1,1,1,1", "q": "p" }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(Condition.self, from: json)
        #expect(decoded.t == "2026-09-22 06:00")
        #expect(decoded.v == "1.5")
        #expect(decoded.s == "0.1")
        #expect(decoded.f == "1,1,1,1")
        #expect(decoded.q == "p")
    }

    @Test("ConditionResult decodes an array of conditions from 'data'")
    func conditionResultDecodesArray() throws {
        let json = """
        { "data": [
            { "t": "2026-09-22 06:00", "v": "1.5", "s": "0.1", "f": "1,1,1,1", "q": "p" },
            { "t": "2026-09-22 06:06", "v": "1.6", "s": "0.1", "f": "1,1,1,1", "q": "v" }
        ] }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(ConditionResult.self, from: json)
        #expect(decoded.data.count == 2)
        #expect(decoded.data[0].q == "p")
        #expect(decoded.data[1].q == "v")
    }

    @Test("Condition encodes back with expected keys")
    func conditionRoundTripsThroughEncoding() throws {
        let condition = Condition(t: "2026-09-22 06:00", v: "1.5", s: "0.1", f: "1,1,1,1", q: "P")
        let data = try JSONEncoder().encode(condition)
        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(object?["t"] as? String == "2026-09-22 06:00")
        #expect(object?["v"] as? String == "1.5")
        #expect(object?["s"] as? String == "0.1")
        #expect(object?["f"] as? String == "1,1,1,1")
        #expect(object?["q"] as? String == "P")
    }
}
