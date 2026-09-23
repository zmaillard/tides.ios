//
//  DefaultTideServiceTests.swift
//  TidesTests
//

import Testing
import Foundation
@testable import tides

struct DefaultTideServiceTests {

    @Test("buildForecastURL uses the reference date for begin_date and +2 days for end_date")
    func buildForecastURLUsesReferenceDateWindow() throws {
        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 10
        components.hour = 12
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        let referenceDate = try #require(calendar.date(from: components))

        let url = DefaultTideService.buildForecastURL(station: "9414290", referenceDate: referenceDate)

        #expect(url.contains("begin_date=20260310"))
        #expect(url.contains("end_date=20260312"))
        #expect(url.contains("station=9414290"))
    }

    @Test("buildForecastURL includes the expected fixed query parameters")
    func buildForecastURLIncludesFixedParameters() {
        let url = DefaultTideService.buildForecastURL(station: "9414290", referenceDate: Date())

        #expect(url.hasPrefix("https://api.tidesandcurrents.noaa.gov/api/prod/datagetter?"))
        #expect(url.contains("product=predictions"))
        #expect(url.contains("datum=MLLW"))
        #expect(url.contains("time_zone=gmt"))
        #expect(url.contains("interval=hilo"))
        #expect(url.contains("units=english"))
        #expect(url.contains("format=json"))
    }

    @Test("buildForecastURL produces a valid URL")
    func buildForecastURLProducesValidURL() {
        let urlString = DefaultTideService.buildForecastURL(station: "9414290", referenceDate: Date())
        #expect(URL(string: urlString) != nil)
    }
}
