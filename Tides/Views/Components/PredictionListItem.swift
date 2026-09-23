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
    
    var body: some View {
        
        
        VStack {
            Text("\(prediction.timeDisplayLocalTime(dateFormat: "yyyy-MM-dd HH:mm")) \(prediction.localTimeZoneDisplay)").font(.headline)
            Text("\(prediction.stage) - \(prediction.value) \(selectedUnits == .english ? "ft" : "m")")
        }
    }
}
