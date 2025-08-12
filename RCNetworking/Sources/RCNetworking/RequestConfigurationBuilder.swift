//
//  RequestConfigurationBuilder.swift
//  RCNetworking
//
//  Created by Jorge Restrepo on 7/08/25.
//

import Foundation

/// A result builder that provides a fluent API for creating `RequestConfiguration` instances.
///
/// This builder allows you to create request configurations using a declarative syntax
/// with convenience functions like `domain()`, `path()`, `method()`, etc.
///
/// ## Usage Example
/// ```swift
/// let config = RequestConfigurationBuilder.buildBlock(
///     domain("api.example.com"),
///     path("/users"),
///     method(.get),
///     headers(["Authorization": "Bearer token"])
/// )
/// ```
///
/// ## Available Components
/// - `domain()` - Set the request domain
/// - `path()` - Set the request path
/// - `method()` - Set the HTTP method
/// - `queryParameters()` - Set URL query parameters
/// - `headers()` - Set HTTP headers
/// - `body()` - Set request body data
/// - `timeout()` - Set request timeout
/// - `cachePolicy()` - Set cache policy
@resultBuilder
public struct RequestConfigurationBuilder {
    /// Builds a `RequestConfiguration` from the provided components.
    ///
    /// This method is called by the result builder to combine all the configuration
    /// components into a single `RequestConfiguration` instance.
    ///
    /// - Parameter components: Variable number of configuration components
    /// - Returns: A fully configured `RequestConfiguration` instance
    public static func buildBlock(_ components: RequestConfigurationComponent...) -> RequestConfiguration {
        var domain = ""
        var path = ""
        var method: HTTPMethod = .get
        var queryParameters: [String: String]?
        var headers: [String: String]?
        var body: Data?
        var timeout = 30.0
        var cachePolicy: CachePolicy = .default
        
        for component in components {
            switch component {
            case .domain(let value):
                domain = value
            case .path(let value):
                path = value
            case .method(let value):
                method = value
            case .queryParameters(let value):
                queryParameters = value
            case .headers(let value):
                headers = value
            case .body(let value):
                body = value
            case .timeout(let value):
                timeout = value
            case .cachePolicy(let value):
                cachePolicy = value
            }
        }
        
        return RequestConfiguration(
            domain: domain,
            path: path,
            method: method,
            queryParameters: queryParameters,
            headers: headers,
            body: body,
            timeout: timeout,
            cachePolicy: cachePolicy
        )
    }
}

/// Individual components that can be used with the `RequestConfigurationBuilder`.
///
/// These are typically created using the convenience functions like `domain()`, `path()`, etc.
/// Each case represents a different aspect of the request configuration.
public enum RequestConfigurationComponent {
    /// Domain component (e.g., "api.example.com")
    case domain(String)
    /// Path component (e.g., "/users/123")
    case path(String)
    /// HTTP method (e.g., .get, .post)
    case method(HTTPMethod)
    /// Query parameters as key-value pairs
    case queryParameters([String: String])
    /// HTTP headers as key-value pairs
    case headers([String: String])
    /// Request body data
    case body(Data)
    /// Request timeout in seconds
    case timeout(TimeInterval)
    /// Cache policy for the request
    case cachePolicy(CachePolicy)
}

// MARK: - Convenience Functions

/// Creates a domain component for the request configuration.
/// - Parameter value: The domain string (e.g., "api.example.com")
/// - Returns: A domain configuration component
public func domain(_ value: String) -> RequestConfigurationComponent {
    .domain(value)
}

/// Creates a path component for the request configuration.
/// - Parameter value: The path string (e.g., "/users/123")
/// - Returns: A path configuration component
public func path(_ value: String) -> RequestConfigurationComponent {
    .path(value)
}

/// Creates a method component for the request configuration.
/// - Parameter value: The HTTP method (e.g., .get, .post)
/// - Returns: A method configuration component
public func method(_ value: HTTPMethod) -> RequestConfigurationComponent {
    .method(value)
}

/// Creates a query parameters component for the request configuration.
/// - Parameter value: Dictionary of query parameters
/// - Returns: A query parameters configuration component
public func queryParameters(_ value: [String: String]) -> RequestConfigurationComponent {
    .queryParameters(value)
}

/// Creates a headers component for the request configuration.
/// - Parameter value: Dictionary of HTTP headers
/// - Returns: A headers configuration component
public func headers(_ value: [String: String]) -> RequestConfigurationComponent {
    .headers(value)
}

/// Creates a body component for the request configuration.
/// - Parameter value: The request body data
/// - Returns: A body configuration component
public func body(_ value: Data) -> RequestConfigurationComponent {
    .body(value)
}

/// Creates a timeout component for the request configuration.
/// - Parameter value: The timeout value in seconds
/// - Returns: A timeout configuration component
public func timeout(_ value: TimeInterval) -> RequestConfigurationComponent {
    .timeout(value)
}

/// Creates a cache policy component for the request configuration.
/// - Parameter value: The cache policy to use
/// - Returns: A cache policy configuration component
public func cachePolicy(_ value: CachePolicy) -> RequestConfigurationComponent {
    .cachePolicy(value)
}
