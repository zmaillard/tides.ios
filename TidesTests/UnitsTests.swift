//
//  UnitsTests.swift
//  TidesTests
//

import Testing
import Foundation
@testable import tides

struct UnitsTests {

    @Test("Metric units description")
    func metricDescription() {
        #expect(Units.metric.description == "Metric")
    }

    @Test("English units description")
    func englishDescription() {
        #expect(Units.english.description == "English")
    }

    @Test("Units round-trips through Codable using its raw value")
    func unitsCodableRoundTrip() throws {
        for unit in Units.allCases {
            let data = try JSONEncoder().encode(unit)
            let decoded = try JSONDecoder().decode(Units.self, from: data)
            #expect(decoded == unit)
        }
    }

    @Test("Units allCases contains exactly metric and english")
    func allCasesContainsExpectedValues() {
        #expect(Units.allCases == [.metric, .english])
    }
}
