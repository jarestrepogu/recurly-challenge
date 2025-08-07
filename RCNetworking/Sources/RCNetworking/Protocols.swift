//
//  Protocols.swift
//  RCNetworking
//
//  Created by Jorge Restrepo on 7/08/25.
//

import Foundation

protocol NetworkClientProtocol {
    func request<T: Decodable>(_ configuration: RequestConfiguration) async throws -> T
}

protocol CacheManagerProtocol {
    func get<T: Decodable>(for key: String) -> T?
    func set<T: Encodable>(_ value: T, for key: String, expiration: TimeInterval?)
    func remove(for key: String)
    func clear()
}

protocol DataFetcherProtocol {
    func fetch<T: Decodable>(_ configuration: RequestConfiguration) async throws -> T
    func fetchWithCache<T: Codable>(_ configuration: RequestConfiguration) async throws -> T
}
