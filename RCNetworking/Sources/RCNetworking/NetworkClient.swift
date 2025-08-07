//
//  NetworkClient.swift
//  RCNetworking
//
//  Created by Jorge Restrepo on 7/08/25.
//

import Foundation

final class NetworkClient: NetworkClientProtocol {
    // Properties
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // Initialization
    init(session: URLSession = .shared, decoder: JSONDecoder = JSONDecoder()) {
        self.session = session
        self.decoder = decoder
    }
    
    // Methods
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
    
    private func buildURL(from configuration: RequestConfiguration) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = configuration.domain
        components.path = configuration.path
        components.queryItems = configuration.queryParameters?.map { URLQueryItem(name: $0, value: $1) }
        return components.url
    }
}
