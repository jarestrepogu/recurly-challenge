//
//  RecurlyDataFetcher.swift
//  RCNetworking
//
//  Created by Jorge Restrepo on 7/08/25.
//

import Foundation

public final class RecurlyDataFetcher {
    private let dataFetcher: DataFetcherProtocol
    
    public init() {
        self.dataFetcher = DataFetcher()
    }
    
    public func configure(@RequestConfigurationBuilder _ builder: () -> RequestConfiguration) -> RequestConfiguration {
        return builder()
    }
    
    public func fetch<T: Decodable>(_ configuration: RequestConfiguration) async throws -> T {
        return try await dataFetcher.fetch(configuration)
    }
    
    public func fetchWithCache<T: Codable>(_ configuration: RequestConfiguration) async throws -> T {
        return try await dataFetcher.fetchWithCache(configuration)
    }
}
