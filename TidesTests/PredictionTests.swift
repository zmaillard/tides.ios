//
//  PredictionTests.swift
//  TidesTests
//

import Testing
import Foundation
@testable import tides

struct PredictionTests {

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

    @Test("Uppercase H maps to high tide")
    func uppercaseHighMapsToHighStage() {
        let prediction = Prediction(id: "2026-09-22 06:00", v: "1.5", type: "H")
        let domain = prediction.toDomain(station: makeStation())
        #expect(domain?.stage == .high)
    }

    @Test("Uppercase L maps to low tide")
    func uppercaseLowMapsToLowStage() {
        let prediction = Prediction(id: "2026-09-22 06:00", v: "1.5", type: "L")
        let domain = prediction.toDomain(station: makeStation())
        #expect(domain?.stage == .low)
    }

    @Test("Lowercase h maps to high tide")
    func lowercaseHighMapsToHighStage() {
        let prediction = Prediction(id: "2026-09-22 06:00", v: "1.5", type: "h")
        let domain = prediction.toDomain(station: makeStation())
        #expect(domain?.stage == .high)
    }

    @Test("Lowercase l maps to low tide")
    func lowercaseLowMapsToLowStage() {
        let prediction = Prediction(id: "2026-09-22 06:00", v: "1.5", type: "l")
        let domain = prediction.toDomain(station: makeStation())
        #expect(domain?.stage == .low)
    }

    @Test("Malformed date string returns nil")
    func malformedDateReturnsNil() {
        let prediction = Prediction(id: "not-a-date", v: "1.5", type: "H")
        #expect(prediction.toDomain(station: makeStation()) == nil)
    }

    @Test("Unknown type code returns nil")
    func unknownTypeCodeReturnsNil() {
        let prediction = Prediction(id: "2026-09-22 06:00", v: "1.5", type: "X")
        #expect(prediction.toDomain(station: makeStation()) == nil)
    }

    @Test("Non-numeric value returns nil")
    func nonNumericValueReturnsNil() {
        let prediction = Prediction(id: "2026-09-22 06:00", v: "abc", type: "H")
        #expect(prediction.toDomain(station: makeStation()) == nil)
    }

    @Test("Valid GMT date string parses to expected date components")
    func validDateParsesCorrectly() throws {
        let prediction = Prediction(id: "2026-09-22 06:30", v: "1.5", type: "H")
        let domain = try #require(prediction.toDomain(station: makeStation()))

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
        let prediction = Prediction(id: "2026-09-22 06:00", v: "1.5", type: "H")
        let domain = try #require(prediction.toDomain(station: station))

        #expect(domain.timeZoneLocal.secondsFromGMT() == -8 * 3600)
    }

    @Test("DST station applies one hour offset adjustment")
    func dstStationAppliesOneHourAdjustment() throws {
        let station = makeStation(observeDST: true, timeZoneOffset: -8)
        let prediction = Prediction(id: "2026-09-22 06:00", v: "1.5", type: "H")
        let domain = try #require(prediction.toDomain(station: station))

        #expect(domain.timeZoneLocal.secondsFromGMT() == -7 * 3600)
    }

    @Test("localTimeZoneDisplay matches station timezone label")
    func localTimeZoneDisplayMatchesStation() throws {
        let station = makeStation(timeZone: "America/Los_Angeles")
        let prediction = Prediction(id: "2026-09-22 06:00", v: "1.5", type: "H")
        let domain = try #require(prediction.toDomain(station: station))

        #expect(domain.localTimeZoneDisplay == "America/Los_Angeles")
    }

    @Test("Prediction decodes with 't' key mapped to id")
    func predictionDecodesWithRemappedIdKey() throws {
        let json = """
        { "t": "2026-09-22 06:00", "v": "1.5", "type": "H" }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(Prediction.self, from: json)
        #expect(decoded.id == "2026-09-22 06:00")
        #expect(decoded.v == "1.5")
        #expect(decoded.type == "H")
    }

    @Test("PredictionResult decodes an array of predictions")
    func predictionResultDecodesArray() throws {
        let json = """
        { "predictions": [
            { "t": "2026-09-22 06:00", "v": "1.5", "type": "H" },
            { "t": "2026-09-22 12:00", "v": "0.2", "type": "L" }
        ] }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(PredictionResult.self, from: json)
        #expect(decoded.predictions.count == 2)
        #expect(decoded.predictions[0].type == "H")
        #expect(decoded.predictions[1].type == "L")
    }

    @Test("Prediction encodes back with 't' key")
    func predictionRoundTripsThroughEncoding() throws {
        let prediction = Prediction(id: "2026-09-22 06:00", v: "1.5", type: "H")
        let data = try JSONEncoder().encode(prediction)
        let object = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        #expect(object?["t"] as? String == "2026-09-22 06:00")
        #expect(object?["v"] as? String == "1.5")
        #expect(object?["type"] as? String == "H")
    }
}
