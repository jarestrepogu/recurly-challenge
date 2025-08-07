//
//  CacheManager.swift
//  RCNetworking
//
//  Created by Jorge Restrepo on 7/08/25.
//

import Foundation

final class CacheManager: CacheManagerProtocol {
    private let cache = NSCache<NSString, CacheEntry>()
    private let fileMAnager = FileManager.default
    private var cacheDirectory: URL
    private let pathComponent = "DataFetcherCache"
    private let defaultExpirationTime: Double = 3600
    
    init() {
        let paths = fileMAnager.urls(for: .cachesDirectory, in: .userDomainMask)
        if #available(iOS 16.0, *) {
            cacheDirectory = paths[0].appending(path: pathComponent)
        } else {
            cacheDirectory = paths[0].appendingPathComponent(pathComponent)
        }
        
        try? fileMAnager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
    }
    
    func get<T>(for key: String) -> T? where T : Decodable {
        let cacheKey = NSString(string: key)
        
        if let entry = cache.object(forKey: cacheKey),
           !entry.isExpired {
            return try? JSONDecoder().decode(T.self, from: entry.data)
        }
        
        var fileURL: URL
        if #available(iOS 16.0, *) {
           fileURL = cacheDirectory.appending(path: key)
        } else {
            fileURL = cacheDirectory.appendingPathComponent(key)
        }
        guard let data = try? Data(contentsOf: fileURL) else { return nil }
        
        let entry = CacheEntry(data: data, expirationDate: Date().addingTimeInterval(defaultExpirationTime))
        if !entry.isExpired {
            cache.setObject(entry, forKey: cacheKey)
            return try? JSONDecoder().decode(T.self, from: data)
        }
        
        return nil
    }
    
    func set<T>(_ value: T, for key: String, expiration: TimeInterval?) where T : Encodable {
        guard let data = try? JSONEncoder().encode(value) else { return }
        
        let expirationDate = expiration.map { Date().addingTimeInterval($0) } ?? Date().addingTimeInterval(defaultExpirationTime)
        let entry = CacheEntry(data: data, expirationDate: expirationDate)
        
        // Set in memory cache
        cache.setObject(entry, forKey: NSString(string: key))
        
        // Set in disk cache
        var fileURL: URL
        if #available(iOS 16.0, *) {
           fileURL = cacheDirectory.appending(path: key)
        } else {
            fileURL = cacheDirectory.appendingPathComponent(key)
        }
        try? data.write(to: fileURL)
    }
    
    func remove(for key: String) {
        cache.removeObject(forKey: NSString(string: key))
        
        var fileURL: URL
        if #available(iOS 16.0, *) {
           fileURL = cacheDirectory.appending(path: key)
        } else {
            fileURL = cacheDirectory.appendingPathComponent(key)
        }
        try? fileMAnager.removeItem(at: fileURL)
    }
    
    func clear() {
        cache.removeAllObjects()
        
        let contents = try? fileMAnager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        contents?.forEach { try? fileMAnager.removeItem(at: $0) }
    }
}

private final class CacheEntry {
    let data: Data
    let expirationDate: Date
    
    var isExpired: Bool {
        Date() > expirationDate
    }
    init(data: Data, expirationDate: Date) {
        self.data = data
        self.expirationDate = expirationDate
    }
}
