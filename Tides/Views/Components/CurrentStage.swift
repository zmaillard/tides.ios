//
//  CurrentStage.swift
//  tides
//
//  Created by Zach Maillard on 9/22/26.
//
import SwiftUI

struct CurrentStage: View {
    @AppStorage("Units") private var selectedUnits: Units = .metric
    let condition: TideCondition
    var body: some View {
        VStack {
            Text("Current Conditions").font(.title)
            Text("\(condition.timeDisplayLocalTime(dateFormat: "yyyy-MM-dd HH:mm")) \(condition.localTimeZoneDisplay)").font(.headline)
            Text("\(condition.value) \(selectedUnits == .english ? "feet" : "meters")").font(.title2)
            
        }.padding()
    }
}
