//
//  NextStage.swift
//  tides
//
//  Created by Zach Maillard on 9/22/26.
//
import SwiftUI
struct NextStage: View {
    @AppStorage("Units") private var selectedUnits: Units = .metric
    let prediction: TidePrediction
    var body: some View {
        VStack {
            Text("\(prediction.stage.description) Tide").font(.title)
            Text("\(prediction.timeDisplayLocalTime(dateFormat: "yyyy-MM-dd HH:mm")) \(prediction.localTimeZoneDisplay)").font(.headline)
            Text("\(prediction.value) \(selectedUnits == .english ? "feet" : "meters")").font(.title2)
            
        }.padding()
    }
}
