//
//  tidesApp.swift
//  tides
//
//  Created by Zach Maillard on 9/12/26.
//

import SwiftUI
import SwiftData

@main
struct TidesApp: App {
    @MainActor
    let appContainer: ModelContainer = {
        do {
            /*
             // Programatically set user defaults for testing
             // delete once settings page is done
             let defaults = UserDefaults()
            defaults.set("9444090", forKey: "stationId", )
            */
            let container = try ModelContainer(for: Station.self)
            
            // Make sure the persistent store is empty. If it's not, return the non-empty container.
            var stateFetchDescriptor = FetchDescriptor<Station>()
            stateFetchDescriptor.fetchLimit = 1
            
            guard try container.mainContext.fetch(stateFetchDescriptor).count == 0 else { return container }
            
            // This code will only run if the persistent store is empty.
            let stations = try StationLoader.loadStationData()
            for station in stations {
                container.mainContext.insert(station)
            }
            
            return container
        } catch {
            fatalError("Failed to create container")
        }
    }()
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(appContainer)
    }
}

