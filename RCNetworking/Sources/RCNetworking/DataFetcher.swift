//
//  DataFetcher.swift
//  RCNetworking
//
//  Created by Jorge Restrepo on 7/08/25.
//

import Foundation

/// Core networking component that handles HTTP requests with optional caching support.
///
/// This class coordinates between the network client and cache manager to provide
/// both direct network requests and cached requests. It implements the caching logic
/// and manages cache keys and expiration times.
final class DataFetcher: DataFetcherProtocol {
    private let networkClient: NetworkClientProtocol
    private let cacheManager: CacheManagerProtocol
    
    /// Creates a new DataFetcher with the specified network client and cache manager.
    ///
    /// - Parameters:
    ///   - networkClient: The network client to use for HTTP requests (defaults to NetworkClient())
    ///   - cacheManager: The cache manager to use for caching (defaults to CacheManager())
    init(networkClient: NetworkClientProtocol = NetworkClient(), cacheManager: CacheManagerProtocol = CacheManager()) {
        self.networkClient = networkClient
        self.cacheManager = cacheManager
    }
    
    /// Fetches data from the network without using any caching mechanism.
    ///
    /// This method delegates directly to the network client, making a fresh network request
    /// every time it's called.
    ///
    /// - Parameters:
    ///   - configuration: The request configuration
    ///   - T: The decodable type to return
    /// - Returns: The decoded data from the network
    /// - Throws: NetworkError if the request fails
    func fetch<T: Decodable>(_ configuration: RequestConfiguration) async throws -> T {
        return try await networkClient.request(configuration)
    }
    
    /// Fetches data with automatic caching support.
    ///
    /// This method first checks the cache for existing data. If cached data is available and not expired,
    /// it returns the cached data immediately. Otherwise, it makes a network request, caches the result,
    /// and returns the fresh data.
    ///
    /// - Parameters:
    ///   - configuration: The request configuration including cache policy
    ///   - T: The codable type to return (must conform to both Encodable and Decodable)
    /// - Returns: The data (from cache if available and valid, otherwise from network)
    /// - Throws: NetworkError if the request fails
    func fetchWithCache<T: Codable>(_ configuration: RequestConfiguration) async throws -> T {
        let cacheKey = generateCacheKey(from: configuration)
        
        if let cached: T = cacheManager.get(for: cacheKey) {
            return cached
        }
        
        let result: T = try await networkClient.request(configuration)
        
        let expiration = getExpirationTime(for: configuration.cachePolicy)
        cacheManager.set(result, for: cacheKey, expiration: expiration)
        
        return result
    }
    
    /// Generates a unique cache key based on the request configuration.
    ///
    /// The cache key is created by combining:
    /// - Domain (e.g., "api.example.com")
    /// - Path (e.g., "/users/123")
    /// - HTTP method (e.g., "GET")
    /// - Query parameters (as dictionary description)
    /// - Request body (base64 encoded)
    ///
    /// All components are joined with "|" separator and then base64 encoded
    /// to create a URL-safe, unique identifier for the request.
    ///
    /// This ensures that different requests (different URLs, methods, parameters, or bodies)
    /// have different cache keys, preventing cache collisions.
    ///
    /// - Parameter configuration: The request configuration
    /// - Returns: A unique string identifier for caching
    private func generateCacheKey(from configuration: RequestConfiguration) -> String {
        let components = [
            configuration.domain,
            configuration.path,
            configuration.method.rawValue,
            configuration.queryParameters?.description ?? "",
            configuration.body?.base64EncodedString() ?? ""
        ]
        return components.joined(separator: "|").data(using: .utf8)?.base64EncodedString() ?? ""
    }
    
    /// Determines the cache expiration time based on the cache policy.
    ///
    /// This method translates the cache policy into an actual expiration time in seconds.
    /// If the policy indicates no caching should occur, it returns `nil`.
    ///
    /// - Parameter policy: The cache policy to evaluate
    /// - Returns: The expiration time in seconds, or `nil` if no caching should occur
    ///
    /// ## Policy Behavior:
    /// - `.default`: Uses default expiration (1 hour)
    /// - `.reloadIgnoringCache`: No caching (returns `nil`)
    /// - `.returnCacheDataElseLoad`: Uses default expiration (1 hour)
    /// - `.returnCacheDataDontLoad`: No caching (returns `nil`)
    /// - `.custom(expiration:)`: Uses the provided expiration time
    private func getExpirationTime(for policy: CachePolicy) -> TimeInterval? {
        let defaulTime: Double = 3600
        switch policy {
        case .default:
            return defaulTime
        case .reloadIgnoringCache:
            return nil
        case .returnCacheDataElseLoad:
            return defaulTime
        case .returnCacheDataDontLoad:
            return nil
        case .custom(let expiration):
            return expiration
        }
    }
}
