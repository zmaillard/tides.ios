//
//  PredictionListItem.swift
//  tides
//
//  Created by Zach Maillard on 9/20/26.
//
import SwiftUI

struct PredictionListItem: View {
    let prediction: Prediction
    
    var body: some View {
        VStack {
            Text(prediction.id).font(.headline)
            Text("\(prediction.type) - \(prediction.v)")
        }
    }
}
