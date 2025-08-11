//
//  ContentView.swift
//  RecurlyChallengeApp
//
//  Created by Jorge Restrepo on 7/08/25.
//

import SwiftUI
import RCNetworking

struct ContentView: View {
    @StateObject private var viewModel = ViewModel()
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button("Get Weather") {
                Task {
                    await viewModel.loadPeriods()
                }
            }
            .disabled(viewModel.isLoading)
            .buttonStyle(.borderedProminent)
            
            if viewModel.isLoading {
                ProgressView("Loading...")
            }
            
            if !viewModel.periods.isEmpty {
                Text("The weater is \(viewModel.periods[0].shortForecast)")
                    .font(.headline)
                Text("The temperature is \(viewModel.periods[0].temperature)")
            }
            
            if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .font(.caption)
            }
        }
        .padding()
    }
}
#Preview {
    ContentView()
}

