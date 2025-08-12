//
//  RecurlyDataFetcher.swift
//  RCNetworking
//
//  Created by Jorge Restrepo on 7/08/25.
//

import Foundation

/// A high-level networking client that provides easy-to-use methods for making HTTP requests
/// with optional caching support.
///
/// This is the main entry point for the RCNetworking library. It provides a clean, type-safe API
/// for configuring and executing network requests using a result builder pattern.
///
/// ## Usage Example
/// ```swift
/// let fetcher = RecurlyDataFetcher()
/// 
/// let config = fetcher.configure {
///     domain("api.example.com")
///     path("/users")
///     method(.get)
///     headers(["Authorization": "Bearer token"])
/// }
/// 
/// let users: [User] = try await fetcher.fetch(config)
/// ```
///
/// ## Features
/// - **Simple Configuration**: Use the result builder pattern for fluent request configuration
/// - **Type Safety**: Full Swift type safety with Codable support
/// - **Caching**: Optional automatic caching with configurable policies
/// - **Error Handling**: Comprehensive error types with localized descriptions
public final class RecurlyDataFetcher {
    private let dataFetcher: DataFetcherProtocol
    
    /// Creates a new instance of RecurlyDataFetcher with default network client and cache manager.
    public init() {
        self.dataFetcher = DataFetcher()
    }
    
    /// Creates a request configuration using a result builder pattern.
    ///
    /// This method provides a fluent API for building request configurations. Use the convenience
    /// functions like `domain()`, `path()`, `method()`, etc. within the builder closure.
    ///
    /// - Parameter builder: A closure that builds the configuration using domain, path, method, etc.
    /// - Returns: A configured `RequestConfiguration` instance
    ///
    /// ## Example
    /// ```swift
    /// let config = fetcher.configure {
    ///     domain("api.example.com")
    ///     path("/users/123")
    ///     method(.get)
    ///     headers(["Authorization": "Bearer token"])
    ///     timeout(30.0)
    /// }
    /// ```
    public func configure(@RequestConfigurationBuilder _ builder: () -> RequestConfiguration) -> RequestConfiguration {
        return builder()
    }
    
    /// Fetches data from the network without caching.
    ///
    /// This method makes a direct network request and returns the decoded data. It does not
    /// use any caching mechanism, so each call will result in a fresh network request.
    ///
    /// - Parameters:
    ///   - configuration: The request configuration
    ///   - T: The decodable type to return
    /// - Returns: The decoded data of type T
    /// - Throws: `NetworkError` if the request fails
    ///
    /// ## Example
    /// ```swift
    /// let users: [User] = try await fetcher.fetch(config)
    /// ```
    public func fetch<T: Decodable>(_ configuration: RequestConfiguration) async throws -> T {
        return try await dataFetcher.fetch(configuration)
    }
    
    /// Fetches data from the network with automatic caching support.
    ///
    /// This method first checks the cache for existing data. If cached data is available and not expired,
    /// it returns the cached data immediately. Otherwise, it makes a network request, caches the result,
    /// and returns the fresh data.
    ///
    /// - Parameters:
    ///   - configuration: The request configuration including cache policy
    ///   - T: The codable type to return (must conform to both Encodable and Decodable)
    /// - Returns: The decoded data of type T (from cache if available and valid)
    /// - Throws: `NetworkError` if the request fails
    ///
    /// ## Example
    /// ```swift
    /// let weather: Weather = try await fetcher.fetchWithCache(config)
    /// ```
    public func fetchWithCache<T: Codable>(_ configuration: RequestConfiguration) async throws -> T {
        return try await dataFetcher.fetchWithCache(configuration)
    }
}
