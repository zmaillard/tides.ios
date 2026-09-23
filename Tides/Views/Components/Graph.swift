//
//  Graph.swift
//  tides
//
//  Created by Zach Maillard on 9/22/26.
//
import SwiftUI
import Charts

struct Graph: View {
    let predictions: [TidePrediction]
    var body: some View {
        Chart(predictions) {
            LineMark(
                x: .value("Time", $0.timeGMT),
                y: .value("Height", $0.value)
            ).interpolationMethod(.cardinal)
        }
    }
}
