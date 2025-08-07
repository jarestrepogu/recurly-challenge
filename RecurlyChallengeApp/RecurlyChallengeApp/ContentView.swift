//
//  ContentView.swift
//  RecurlyChallengeApp
//
//  Created by Jorge Restrepo on 7/08/25.
//

import SwiftUI
import RCNetworking

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
    
    private func loadData() {
        
    }
}

#Preview {
    ContentView()
}
