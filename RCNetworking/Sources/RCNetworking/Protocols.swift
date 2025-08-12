//
//  Protocols.swift
//  RCNetworking
//
//  Created by Jorge Restrepo on 7/08/25.
//

import Foundation

/// Protocol defining the interface for network clients.
///
/// This protocol abstracts the network request functionality, allowing for
/// easy testing and dependency injection.
protocol NetworkClientProtocol {
    func request<T: Decodable>(_ configuration: RequestConfiguration) async throws -> T
}

/// Protocol defining the interface for cache managers.
///
/// This protocol abstracts the caching functionality, allowing for
/// easy testing and dependency injection.
protocol CacheManagerProtocol {
    func get<T: Decodable>(for key: String) -> T?
    func set<T: Encodable>(_ value: T, for key: String, expiration: TimeInterval?)
    func remove(for key: String)
    func clear()
}

/// Protocol defining the interface for data fetchers.
///
/// This protocol abstracts the data fetching functionality, allowing for
/// easy testing and dependency injection.
protocol DataFetcherProtocol {
    func fetch<T: Decodable>(_ configuration: RequestConfiguration) async throws -> T
    func fetchWithCache<T: Codable>(_ configuration: RequestConfiguration) async throws -> T
}
