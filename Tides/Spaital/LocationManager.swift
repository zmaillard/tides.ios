//
//  LocationManager.swift
//  tides
//
//  Created by Zach Maillard on 9/25/26.
//
import CoreLocation

protocol LocationManager {
    var currentLocation: CLLocation { get async throws}
}
