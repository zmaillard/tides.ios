//
//  DefaultStationSearch.swift
//  tides
//
//  Created by Zach Maillard on 9/25/26.
//

import Foundation
import RTree

struct DefaultStationSearch: StationSearch {
    private let indexState = "TideStationRTree.db"
    private let indexURL: URL?

    init(indexURL: URL? = nil) {
        self.indexURL = indexURL
    }

    private var resolvedIndexURL: URL? {
        indexURL ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
            .first?.appendingPathComponent(indexState)
    }
    
    func BuildIndex(stations: [Station]) throws {
        guard let rTreeIndex = resolvedIndexURL else {
           return
        }
        
        var tree = try RTree<StationSpatialObject>(path: rTreeIndex)
        // check if tree has data in it
        // if so - it is already loaded
        if tree.size > 0 {
            return
        }
        
        for s in stations {
            let stationSpatial = StationSpatialObject(point: Point2D(x: Double(s.longitude), y: Double(s.latitude)), stationId: s.id)
            try tree.insert(stationSpatial)
        }
        
        // Need exception here
    }
    
    func FindNearestStation(search: Point2D) throws -> String? {
        guard let rTreeIndex = resolvedIndexURL else {
           return nil
        }
        
        var tree = try RTree<StationSpatialObject>(path: rTreeIndex)
        let station = try tree.nearestNeighbor(search)
        
        return station?.stationId
        
    }
}
