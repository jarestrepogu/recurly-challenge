//
//  RequestConfigurationBuilder.swift
//  RCNetworking
//
//  Created by Jorge Restrepo on 7/08/25.
//

import Foundation

@resultBuilder
public struct RequestConfigurationBuilder {
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

public enum RequestConfigurationComponent {
    case domain(String)
    case path(String)
    case method(HTTPMethod)
    case queryParameters([String: String])
    case headers([String: String])
    case body(Data)
    case timeout(TimeInterval)
    case cachePolicy(CachePolicy)
}

// MARK: - Convenience Functions
public func domain(_ value: String) -> RequestConfigurationComponent {
    .domain(value)
}
public func path(_ value: String) -> RequestConfigurationComponent {
    .path(value)
}
public func method(_ value: HTTPMethod) -> RequestConfigurationComponent {
    .method(value)
}
public func queryParameters(_ value: [String: String]) -> RequestConfigurationComponent {
    .queryParameters(value)
}
public func headers(_ value: [String: String]) -> RequestConfigurationComponent {
    .headers(value)
}
public func body(_ value: Data) -> RequestConfigurationComponent {
    .body(value)
}
public func timeout(_ value: TimeInterval) -> RequestConfigurationComponent {
    .timeout(value)
}
public func cachePolicy(_ value: CachePolicy) -> RequestConfigurationComponent {
    .cachePolicy(value)
}
