//
//  SettingsView.swift
//  tides
//
//  Created by Zach Maillard on 9/12/26.
//
import SwiftUI
import SwiftData

struct SettingsView: View {
    @AppStorage("StationId") private var selectedStation = ""
    @AppStorage("Units") private var selectedUnits: Units = .english
    
    @Query(sort: \Station.name) private var stations: [Station]
    
    
    var body: some View {
        List {
            Picker("Station", selection: $selectedStation) {
                ForEach(stations){ value in
                    Text(value.name)//.tag(value.id)
                }
            }
            Picker("Units", selection: $selectedUnits) {
                Text(Units.english.description).tag(Units.english)
                Text(Units.metric.description).tag(Units.metric)
            }
        }
    }
}
