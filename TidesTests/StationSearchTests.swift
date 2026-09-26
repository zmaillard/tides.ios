//
//  StationSearchTests.swift
//  TidesTests
//

import Foundation
import RTree
import Testing
@testable import tides

@MainActor
struct StationSearchTests {

    private func makeStation(id: String, latitude: Float, longitude: Float) -> Station {
        Station(
            timeZone: "GMT",
            name: id,
            isTidal: true,
            state: "CA",
            greatLakes: false,
            region: "Pacific",
            tideType: "Mixed Semidiurnal",
            id: id,
            latitude: latitude,
            longitude: longitude,
            observeDST: false,
            timeZoneOffset: 0
        )
    }

    private func makeIndexURL() throws -> (directory: URL, index: URL) {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return (directory, directory.appendingPathComponent("stations.db"))
    }

    @Test("BuildIndex stores station coordinates and nearest search returns the closest station")
    func buildsAndSearchesIndex() throws {
        let paths = try makeIndexURL()
        defer { try? FileManager.default.removeItem(at: paths.directory) }
        let search = DefaultStationSearch(indexURL: paths.index)
        let stations = [
            makeStation(id: "far", latitude: 40, longitude: -120),
            makeStation(id: "near", latitude: 37, longitude: -122)
        ]

        try search.BuildIndex(stations: stations)
        let result = try search.FindNearestStation(search: Point2D(x: -122.1, y: 37.1))

        #expect(FileManager.default.fileExists(atPath: paths.index.path))
        #expect(result == "near")
    }

    @Test("BuildIndex does not duplicate entries when the index already contains stations")
    func buildIndexPreservesExistingIndex() throws {
        let paths = try makeIndexURL()
        defer { try? FileManager.default.removeItem(at: paths.directory) }
        let search = DefaultStationSearch(indexURL: paths.index)

        try search.BuildIndex(stations: [makeStation(id: "original", latitude: 10, longitude: 10)])
        try search.BuildIndex(stations: [makeStation(id: "new", latitude: 0, longitude: 0)])

        let result = try search.FindNearestStation(search: Point2D(x: 0, y: 0))
        #expect(result == "original")
    }

    @Test("Nearest search returns nil for an empty index")
    func emptyIndexReturnsNil() throws {
        let paths = try makeIndexURL()
        defer { try? FileManager.default.removeItem(at: paths.directory) }
        let search = DefaultStationSearch(indexURL: paths.index)

        try search.BuildIndex(stations: [])

        #expect(try search.FindNearestStation(search: Point2D(x: 0, y: 0)) == nil)
    }

    @Test("Point2D exposes two dimensions and supports indexed reads and writes")
    func pointProvidesTwoDimensionalSubscripts() {
        var point = Point2D(x: 1, y: 2)

        #expect(point.dimensions() == 2)
        #expect(point[0] == 1)
        #expect(point[1] == 2)
        point[0] = 3
        point[1] = 4
        #expect(point == Point2D(x: 3, y: 4))
        #expect(Point2D.from(value: 5) == Point2D(x: 5, y: 5))
    }

    @Test("Station spatial object calculates distance, bounds, and point containment")
    func spatialObjectCalculatesGeometry() {
        let object = StationSpatialObject(
            point: Point2D(x: 3, y: 4),
            stationId: "station"
        )
        let bounds = object.minimumBoundingRectangle()

        #expect(object.distanceSquared(point: Point2D(x: 0, y: 0)) == 25)
        #expect(object.contains(point: Point2D(x: 3, y: 4)))
        #expect(!object.contains(point: Point2D(x: 3, y: 5)))
        #expect(bounds.lower == object.point)
        #expect(bounds.upper == object.point)
    }
}
