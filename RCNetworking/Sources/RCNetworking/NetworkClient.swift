//
//  NetworkClient.swift
//  RCNetworking
//
//  Created by Jorge Restrepo on 7/08/25.
//

import Foundation

/// Low-level HTTP client that handles network requests and response processing.
///
/// This class is responsible for:
/// - Building URLs from request configurations
/// - Making HTTP requests using URLSession
/// - Handling response validation and error processing
/// - Decoding response data into the expected type
///
/// It provides a clean abstraction over URLSession and handles common
/// networking tasks like URL construction, header management, and error handling.
final class NetworkClient: NetworkClientProtocol {
    // Properties
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // Initialization
    
    /// Creates a new NetworkClient with the specified session and decoder.
    ///
    /// - Parameters:
    ///   - session: The URLSession to use for network requests (defaults to .shared)
    ///   - decoder: The JSONDecoder to use for response decoding (defaults to JSONDecoder())
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    // Methods
    
    /// Makes an HTTP request based on the provided configuration.
    ///
    /// This method builds a URL from the configuration, creates an HTTP request,
    /// executes it using URLSession, validates the response, and decodes the data
    /// into the expected type.
    ///
    /// - Parameters:
    ///   - configuration: The request configuration containing URL, method, headers, etc.
    ///   - T: The decodable type to return
    /// - Returns: The decoded response data
    /// - Throws: NetworkError if the request fails or response is invalid
    func request<T>(_ configuration: RequestConfiguration) async throws -> T where T : Decodable {
        guard let url = buildURL(from: configuration) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = configuration.method.rawValue
        request.timeoutInterval = configuration.timeout
        request.httpBody = configuration.body
        // Headers
        configuration.headers?.forEach { request.setValue($0, forHTTPHeaderField: $1) }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.networkError(NSError(domain: ">>> Invalid response", code: -1))
            }
            guard (200...299).contains(httpResponse.statusCode) else {
                throw NetworkError.serverError(httpResponse.statusCode)
            }
            
            return try decoder.decode(T.self, from: data)
        } catch let error as NetworkError {
            throw error
        } catch {
            throw NetworkError.networkError(error)
        }
    }
    
    /// Builds a URL from the request configuration.
    ///
    /// This method constructs a URL by combining the domain, path, and query parameters
    /// from the configuration. It uses URLComponents to ensure proper URL encoding
    /// and handles the various components correctly.
    ///
    /// - Parameter configuration: The request configuration
    /// - Returns: The constructed URL, or nil if the URL cannot be built
    private func buildURL(from configuration: RequestConfiguration) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = configuration.domain
        components.path = configuration.path
        components.queryItems = configuration.queryParameters?.map { URLQueryItem(name: $0, value: $1) }
        return components.url
    }
}
