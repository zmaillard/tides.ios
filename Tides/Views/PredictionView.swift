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
            case .loaded(let predictions):
                 VStack {
                     Text(station[0].name).font(.title)
                     NextStage(prediction: predictions.first!)
                     NextStage(prediction: predictions[1])
                     Graph(predictions: predictions)
                 }
                 /*List(predictions){ pred in
                    PredictionListItem(prediction: pred)
                }.navigationTitle(forecastViewModel.title)*/
            case .error(let error):
                Text(error).foregroundStyle(Color.red)
            }
        }
        .task{
            if !station.isEmpty {
                await forecastViewModel.fetch(for: station[0])
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
