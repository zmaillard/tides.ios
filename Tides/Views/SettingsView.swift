//
//  SettingsView.swift
//  tides
//
//  Created by Zach Maillard on 9/12/26.
//
import SwiftUI
import CoreLocation
import MapKit
internal import Combine

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @FocusState private var isFocusedField: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Type address", text: $viewModel.searchableText)
                .padding()
                .autocorrectionDisabled(true)
                .focused($isFocusedField)
                .font(.title)
                .onReceive(
                  viewModel.$searchableText.debounce(for: .seconds(1), scheduler: DispatchQueue.main)
                 ){
                     viewModel.searchAddress($0)
                 }
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    viewModel.searchAddress(viewModel.searchableText)
                    isFocusedField = false
                }
            List {
                
            }
        }
    }
}
