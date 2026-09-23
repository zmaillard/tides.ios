//
//  PredictionListItem.swift
//  tides
//
//  Created by Zach Maillard on 9/20/26.
//
import SwiftUI

struct PredictionListItem: View {
    @AppStorage("Units") private var selectedUnits: Units = .metric
    let prediction: TidePrediction
    let station: Station
    let dateString: String
    
    init(prediction: TidePrediction, station: Station) {
        self.prediction = prediction
        self.station = station
        
        var currentDate = prediction.time
        let localOffset: Int = station.observeDST ? station.timeZoneOffset + 1 : station.timeZoneOffset
        let targetTz = TimeZone(secondsFromGMT: 60 * 60 * localOffset)

         
        // 1) Create a DateFormatter() object.
        let format = DateFormatter()
         
        // 2) Set the current timezone to .current, or America/Chicago.
        format.timeZone = targetTz
         
        // 3) Set the format of the altered date.
        format.dateFormat = "yyyy-MM-dd HH:mm"
         
        // 4) Set the current date, altered by timezone.
        dateString = format.string(from: currentDate)

    }
    
    
    var body: some View {
        
        
        VStack {
            Text("\(dateString) \(station.timeZone)").font(.headline)
            Text("\(prediction.stage) - \(prediction.value) \(selectedUnits == .english ? "ft" : "m")")
        }
    }
}
