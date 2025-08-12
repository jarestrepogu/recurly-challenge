//
//  RequestConfiguration.swift
//  RCNetworking
//
//  Created by Jorge Restrepo on 7/08/25.
//

import Foundation

/// Configuration for network requests including URL, method, headers, and caching behavior.
///
/// This struct contains all the necessary information to make an HTTP request. It's typically
/// created using the `RequestConfigurationBuilder` for a more fluent API.
///
/// ## Example
/// ```swift
/// let config = RequestConfiguration(
///     domain: "api.example.com",
///     path: "/users",
///     method: .get,
///     queryParameters: ["page": "1"],
///     headers: ["Authorization": "Bearer token"],
///     body: nil,
///     timeout: 30.0,
///     cachePolicy: .default
/// )
/// ```
public struct RequestConfiguration: Sendable {
    /// The domain/host for the request (e.g., "api.example.com")
    let domain: String
    /// The path component of the URL (e.g., "/users/123")
    let path: String
    /// The HTTP method to use for the request
    let method: HTTPMethod
    /// Optional query parameters to append to the URL
    let queryParameters: [String: String]?
    /// Optional HTTP headers to include in the request
    let headers: [String: String]?
    /// Optional request body data
    let body: Data?
    /// Request timeout in seconds (default: 30.0)
    let timeout: TimeInterval
    /// Cache policy for the request
    let cachePolicy: CachePolicy
    
}

/// HTTP methods supported by the networking library.
public enum HTTPMethod: String, Sendable {
    /// GET request - typically used for retrieving data
    case get = "GET"
    /// POST request - typically used for creating new resources
    case post = "POST"
    /// PUT request - typically used for updating entire resources
    case put = "PUT"
    /// DELETE request - typically used for removing resources
    case delete = "DELETE"
    /// PATCH request - typically used for partial updates
    case patch = "PATCH"
}

/// Cache policies that control how requests are cached and retrieved.
///
/// These policies determine whether and how long data should be cached, and whether
/// cached data should be used when available.
public enum CachePolicy: Sendable {
    /// Uses default expiration time (1 hour) and normal cache behavior
    case `default`
    /// Always fetches fresh data from the network, ignoring any cached data
    case reloadIgnoringCache
    /// Returns cached data if available and not expired, otherwise fetches fresh data
    case returnCacheDataElseLoad
    /// Returns cached data only if available, never makes network requests
    case returnCacheDataDontLoad
    /// Uses a custom expiration time in seconds
    case custom(expiration: TimeInterval)
}

// MARK: - Error types

/// Network-related errors that can occur during HTTP requests.
///
/// This enum provides comprehensive error handling with localized descriptions
/// for better user experience and debugging.
public enum NetworkError: LocalizedError, Sendable {
    /// The URL could not be constructed from the provided configuration
    case invalidURL
    /// No data was received from the server
    case noData
    /// Failed to decode the response data into the expected type
    case decodingError(Error)
    /// Server returned an error status code
    case serverError(Int)
    /// A network-level error occurred (connection, DNS, etc.)
    case networkError(Error)
    /// The request timed out
    case timeout
    /// An error occurred while accessing the cache
    case cacheError(Error)
    
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return ">>> Invalid URL"
        case .noData:
            return ">>> No data received"
        case .decodingError(let error):
            return ">>> Decoding error: \(error.localizedDescription)"
        case .serverError(let code):
            return ">>> Server error with code: \(code)"
        case .networkError(let error):
            return ">>> Network error: \(error.localizedDescription)"
        case .timeout:
            return ">>> Request timeout"
        case .cacheError(let error):
            return ">>> Cache error: \(error.localizedDescription)"
        }
    }
}
