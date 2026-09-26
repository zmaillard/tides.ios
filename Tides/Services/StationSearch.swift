//
//  StationSearch.swift
//  tides
//
//  Created by Zach Maillard on 9/25/26.
//

protocol StationSearch {
    func BuildIndex(stations: [Station]) throws
    func FindNearestStation(search: Point2D) throws -> String?
}
