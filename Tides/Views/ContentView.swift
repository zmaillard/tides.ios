//
//  ContentView.swift
//  tides
//
//  Created by Zach Maillard on 9/12/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var navigator = Navigator()
    @AppStorage("StationId") private var stationId = ""

    
    var body: some View {
        @Bindable var navigator = navigator
        NavigationStack(path: $navigator.path) {
            PredictionView(stationId: stationId)
                .navigationDestination(for: Screen.self) { route in
                    switch route {
                    case .root:
                        PredictionView(stationId: stationId)
                    case .settings:
                        SettingsView()
                    }
                }
        }.onOpenURL{ url in
            navigator.handleDeepLink(url)
        }.environment(navigator)
    }
}

#Preview {
    ContentView()
}
