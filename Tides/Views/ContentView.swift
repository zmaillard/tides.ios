//
//  ContentView.swift
//  tides
//
//  Created by Zach Maillard on 9/12/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) var modelContext
    @AppStorage("StationId") private var stationId = ""
    
    @Query private var station: [Station]
    @State var forecastViewModel = ForecastViewModel()
    
    init() {
        let predicate = #Predicate<Station> { station in
            station.id == stationId
        }
        
        _station = Query(filter: predicate)
    }
    
    var body: some View {
        VStack {
            Text(stationId)
            if !station.isEmpty {
                Text(station[0].name)
            }
            switch forecastViewModel.state {
            case .idle:
                Text("No data yet")
            case .loading:
                ProgressView {
                    Text("Loading...")
                }.navigationTitle("Loading Forecast")
            case .loaded(let predictions):
                List(predictions){ pred in
                    PredictionListItem(prediction: pred)
                }.navigationTitle(forecastViewModel.title)
            case .error(let error):
                Text(error).foregroundStyle(Color.red)
            }
        }
        .padding()
        .task {
            if !station.isEmpty {
                await forecastViewModel.fetch(for: station[0])
            }
        }
    }
}

#Preview {
    ContentView()
}
