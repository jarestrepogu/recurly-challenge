//
//  DataFetcher.swift
//  RCNetworking
//
//  Created by Jorge Restrepo on 7/08/25.
//

import Foundation

final class DataFetcher: DataFetcherProtocol {
    private let networkClient: NetworkClientProtocol
    private let cacheManager: CacheManagerProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient(), cacheManager: CacheManagerProtocol = CacheManager()) {
        self.networkClient = networkClient
        self.cacheManager = cacheManager
    }
    
    func fetch<T: Decodable>(_ configuration: RequestConfiguration) async throws -> T {
        return try await networkClient.request(configuration)
    }
    
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
