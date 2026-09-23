//
//  StationLoaderTests.swift
//  TidesTests
//

import Testing
import Foundation
@testable import tides

struct StationLoaderTests {

    @Test("StationImport maps every field to the correct Station property")
    func stationImportMapsFieldsToStation() {
        let stationImport = StationImport(
            id: "9414290",
            timezone: "America/Los_Angeles",
            name: "San Francisco",
            tidal: true,
            state: "CA",
            greatlakes: false,
            region: "Pacific",
            tideType: "Mixed Semidiurnal",
            lat: 37.8063,
            lng: -122.4659,
            observedst: true,
            timezonecorr: -8
        )

        let station = stationImport.toStation()

        #expect(station.id == "9414290")
        #expect(station.timeZone == "America/Los_Angeles")
        #expect(station.name == "San Francisco")
        #expect(station.isTidal == true)
        #expect(station.state == "CA")
        #expect(station.greatLakes == false)
        #expect(station.region == "Pacific")
        #expect(station.tideType == "Mixed Semidiurnal")
        #expect(station.latitude == 37.8063)
        #expect(station.longitude == -122.4659)
        #expect(station.observeDST == true)
        #expect(station.timeZoneOffset == -8)
    }

    @Test("StationImportFile decodes a list of stations")
    func stationImportFileDecodesStationsArray() throws {
        let json = """
        {
            "version": "1.0",
            "stations": [
                {
                    "id": "9414290",
                    "timezone": "America/Los_Angeles",
                    "name": "San Francisco",
                    "tidal": true,
                    "state": "CA",
                    "greatlakes": false,
                    "region": "Pacific",
                    "tideType": "Mixed Semidiurnal",
                    "lat": 37.8063,
                    "lng": -122.4659,
                    "observedst": true,
                    "timezonecorr": -8
                }
            ]
        }
        """.data(using: .utf8)!

        let decoded = try JSONDecoder().decode(StationImportFile.self, from: json)
        #expect(decoded.version == "1.0")
        #expect(decoded.stations.count == 1)
        #expect(decoded.stations[0].id == "9414290")
    }

    @Test("Decoding malformed station JSON throws a decoding error")
    func malformedStationJSONThrowsDecodingError() {
        let json = "{ \"version\": \"1.0\" }".data(using: .utf8)!

        #expect(throws: DecodingError.self) {
            _ = try JSONDecoder().decode(StationImportFile.self, from: json)
        }
    }
}
