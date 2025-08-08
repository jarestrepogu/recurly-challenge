//
//  ViewModel.swift
//  RecurlyChallengeApp
//
//  Created by Jorge Restrepo on 7/08/25.
//

import SwiftUI
import RCNetworking
import Combine

@MainActor
final class ViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: NetworkError?
    @Published var progress: Double = 0.0
    @Published var periods: [Period] = []
    
    private let chainBuilder = RequestChainBuilder()
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Bind chain builder properties to view model
        chainBuilder.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        chainBuilder.$error
            .assign(to: \.error, on: self)
            .store(in: &cancellables)
        chainBuilder.$progress
            .assign(to: \.progress, on: self)
            .store(in: &cancellables)
    }
    
    func loadPeriods() async {
        let firstConfig = chainBuilder.fetcher.configure {
            domain("api.weather.gov")
            path("/points/37.2883,-121.8434")
            method(.get)
        }
        
        if let secondResponse: ForecastModel = await chainBuilder.chainTwoRequest(
            first: firstConfig,
            then: { (weaterModel: WeaterModel) in
            let secondURL = weaterModel.properties.forecast
            
            guard let url = URL(string: secondURL),
                  let host = url.host(percentEncoded: true) else {
                return self.chainBuilder.fetcher.configure {
                    domain("api.weather.gov")
                    method(.get)
                }
            }
            
            return self.chainBuilder.fetcher.configure {
                domain(host)
                path(url.path(percentEncoded: true))
                method(.get)
            }
        }
        ) {
            self.periods = secondResponse.properties.periods
        }
    }
    
    func clearData() {
        periods = []
        clearError()
    }
    func clearError() {
        chainBuilder.clearError()
    }
}

@MainActor
final class RequestChainBuilder: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: NetworkError?
    @Published var progress: Double = 0.0
    
    let fetcher = RecurlyDataFetcher()
    
    func chainTwoRequest<T: Decodable, U: Decodable>(first: RequestConfiguration, then: @escaping (T) -> RequestConfiguration) async -> U? {
        isLoading = true
        error = nil
        progress = 0.0
        
        defer {
            isLoading = false
            progress = 1.0
        }
        
        do {
            progress = 0.3
            let firstResult: T = try await fetcher.fetch(first)
            
            progress = 0.6
            let secondConfig = then(firstResult)
            
            progress = 0.8
            let secondResult: U = try await fetcher.fetch(secondConfig)
            return secondResult
        } catch {
            self.error = NetworkError.networkError(error)
            return nil
        }
    }
    
    func clearError() {
        self.error = nil
    }
}
