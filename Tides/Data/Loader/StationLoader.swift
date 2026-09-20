//
//  StationLoader.swift
//  tides
//
//  Created by Zach Maillard on 9/19/26.
//

import Foundation

struct StationImportFile: Decodable {
    let version: String
    let stations: [StationImport]
}

struct StationImport: Equatable, Decodable {
    
    let id: String
    let timezone: String
    let name: String
    let tidal: Bool
    let state: String
    let greatlakes: Bool
    let region: String
    let tideType: String
    let lat: Float
    let lng: Float
    let observedst: Bool
    var timezonecorr: Int
    
    func toStation() -> Station {
        return Station(timeZone: self.timezone, name: self.name, isTidal: self.tidal, state: self.state, greatLakes: self.greatlakes, region: self.region, tideType: self.tideType, id: self.id, latitude: self.lat, longitude: self.lng, observeDST: self.observedst, timeZoneOffset: self.timezonecorr)
    }
}

struct StationLoader {
    static func loadStationData() throws -> [Station] {
        guard let url = Bundle.main.url(forResource: "station", withExtension: "json") else {
            throw APIError.invalidURL
        }

        do {
            let data = try Data(contentsOf: url)
            let stationImportFile =  try JSONDecoder().decode(StationImportFile.self, from: data)
        
            return stationImportFile.stations.map { $0.toStation() }
            
        } catch let error as DecodingError {
            throw APIError.decoding(error)
        } catch {
            throw APIError.networkError(error)
        }

    }
}
