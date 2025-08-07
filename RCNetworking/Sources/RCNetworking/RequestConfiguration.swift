//
//  RequestConfiguration.swift
//  RCNetworking
//
//  Created by Jorge Restrepo on 7/08/25.
//

import Foundation

public struct RequestConfiguration: Sendable {
    let domain: String
    let path: String
    let method: HTTPMethod
    let queryParameters: [String: String]?
    let headers: [String: String]?
    let body: Data?
    let timeout: TimeInterval
    let cachePolicy: CachePolicy
    
}

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

public enum CachePolicy: Sendable {
    case `default`
    case reloadIgnoringCache
    case returnCacheDataElseLoad
    case returnCacheDataDontLoad
    case custom(expiration: TimeInterval)
}

// MARK: - Error types
public enum NetworkError: LocalizedError, Sendable {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int)
    case networkError(Error)
    case timeout
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
