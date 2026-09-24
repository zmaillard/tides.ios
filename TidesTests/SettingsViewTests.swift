//
//  SettingsViewTests.swift
//  TidesTests
//
//  These tests exercise the exact FetchDescriptor/#Predicate that
//  SettingsView's `@Query(filter: #Predicate<Station>{ !$0.greatLakes }, sort: \Station.name)`
//  relies on to populate its station picker. We intentionally avoid rendering
//  SettingsView itself with ViewInspector: combining SwiftData's `@Query` with
//  ViewInspector's `.inspect()` (hosted or not) has been observed to deadlock
//  in this project's toolchain (see PredictionView investigation). Testing the
//  underlying query directly against an in-memory ModelContainer gives full
//  coverage of the "Great Lakes stations are excluded" behavior without that risk.
//

import Testing
import Foundation
import SwiftData
@testable import tides

@MainActor
struct SettingsViewTests {

    private func makeStation(
        id: String,
        name: String,
        greatLakes: Bool
    ) -> Station {
        Station(
            timeZone: "GMT",
            name: name,
            isTidal: !greatLakes,
            state: "MI",
            greatLakes: greatLakes,
            region: greatLakes ? "Great Lakes - Detroit River" : "Pacific",
            tideType: greatLakes ? "Great Lakes" : "Mixed Semidiurnal",
            id: id,
            latitude: 0,
            longitude: 0,
            observeDST: false,
            timeZoneOffset: 0
        )
    }

    private func makeContainer(with stations: [Station]) throws -> ModelContainer {
        let schema = Schema([Station.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(for: schema, configurations: [configuration])
        for station in stations {
            container.mainContext.insert(station)
        }
        return container
    }

    /// Mirrors SettingsView's `@Query(filter: #Predicate<Station>{ !$0.greatLakes }, sort: \Station.name)`.
    private func fetchStationPickerOptions(in context: ModelContext) throws -> [Station] {
        let descriptor = FetchDescriptor<Station>(
            predicate: #Predicate<Station> { !$0.greatLakes },
            sortBy: [SortDescriptor(\.name)]
        )
        return try context.fetch(descriptor)
    }

    @Test("Great Lakes stations are excluded from the settings station picker query")
    func greatLakesStationsAreExcluded() throws {
        let greatLakesStation = makeStation(id: "9044020", name: "Gibraltar, MI", greatLakes: true)
        let tidalStationA = makeStation(id: "8735180", name: "Dauphin Island, AL", greatLakes: false)
        let tidalStationB = makeStation(id: "9414290", name: "San Francisco, CA", greatLakes: false)

        let container = try makeContainer(with: [greatLakesStation, tidalStationA, tidalStationB])

        let results = try fetchStationPickerOptions(in: container.mainContext)

        #expect(results.count == 2)
        #expect(!results.contains { $0.id == greatLakesStation.id })
        #expect(results.contains { $0.id == tidalStationA.id })
        #expect(results.contains { $0.id == tidalStationB.id })
    }

    @Test("Station picker query results are sorted by name")
    func resultsAreSortedByName() throws {
        let stationZ = makeStation(id: "1", name: "Zion Station", greatLakes: false)
        let stationA = makeStation(id: "2", name: "Anchorage Station", greatLakes: false)
        let stationM = makeStation(id: "3", name: "Miami Station", greatLakes: false)

        let container = try makeContainer(with: [stationZ, stationA, stationM])

        let results = try fetchStationPickerOptions(in: container.mainContext)

        #expect(results.map(\.name) == ["Anchorage Station", "Miami Station", "Zion Station"])
    }

    @Test("Query returns an empty list when every station is a Great Lakes station")
    func returnsEmptyWhenAllStationsAreGreatLakes() throws {
        let stationA = makeStation(id: "9044020", name: "Gibraltar, MI", greatLakes: true)
        let stationB = makeStation(id: "9075014", name: "Bar Point, MI", greatLakes: true)

        let container = try makeContainer(with: [stationA, stationB])

        let results = try fetchStationPickerOptions(in: container.mainContext)

        #expect(results.isEmpty)
    }

    @Test("Query returns the single non-Great-Lakes station when mixed with Great Lakes stations")
    func returnsOnlyNonGreatLakesStationFromMixedSet() throws {
        let greatLakesA = makeStation(id: "9044020", name: "Gibraltar, MI", greatLakes: true)
        let greatLakesB = makeStation(id: "9075014", name: "Bar Point, MI", greatLakes: true)
        let tidalStation = makeStation(id: "8735180", name: "Dauphin Island, AL", greatLakes: false)

        let container = try makeContainer(with: [greatLakesA, greatLakesB, tidalStation])

        let results = try fetchStationPickerOptions(in: container.mainContext)

        #expect(results.count == 1)
        #expect(results.first?.id == tidalStation.id)
    }
}
