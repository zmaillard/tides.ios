//
//  PredictionView.swift
//  tides
//
//  Created by Zach Maillard on 9/20/26.
//
import SwiftUI
import SwiftData

struct PredictionView: View {
    @Environment(Navigator.self) private var navigator
    @AppStorage("Units") private var selectedUnits: Units = .english

    @Query private var station: [Station]
    @State var forecastViewModel = ForecastViewModel()
    
    init(stationId: String) {
        let predicate = #Predicate<Station> { station in
            station.id == stationId
        }
        
        _station = Query(filter: predicate)
    }
    
    var body: some View {
        Group {
             switch forecastViewModel.state {
            case .idle:
                Text("No data yet")
            case .loading:
                ProgressView {
                    Text("Loading...")
                }.navigationTitle("Loading Forecast")
            case .loaded(let conditions):
                 VStack {
                     Text(station[0].name).font(.title)
                     if let current = conditions.currentCondition {
                         CurrentStage(condition: current)
                     }
                     if let first = conditions.predictions.first {
                         NextStage(prediction: first)
                     }
                     if conditions.predictions.count > 1 {
                         NextStage(prediction: conditions.predictions[1])
                     }
                     Graph(predictions: conditions.predictions)
                 }
            case .error(let error):
                Text(error).foregroundStyle(Color.red)
            }
        }
        .task{
            if !station.isEmpty {
                await forecastViewModel.fetch(for: station[0], units: selectedUnits)
            }
        }.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Settings", systemImage: "gear"){
                    navigator.push(.settings)
                }.labelStyle(.iconOnly)
                    
            }
        }
    }
    
}

#Preview {
    PredictionView(stationId: "")
}
