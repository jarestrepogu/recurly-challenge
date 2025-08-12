//
//  CacheManager.swift
//  RCNetworking
//
//  Created by Jorge Restrepo on 7/08/25.
//

import Foundation

/// Manages both memory and disk caching for network requests.
///
/// This class provides a two-tier caching system:
/// 1. **Memory Cache**: Fast access using NSCache for recently used data
/// 2. **Disk Cache**: Persistent storage in the app's cache directory
///
/// The cache automatically handles expiration times and provides methods for
/// getting, setting, removing, and clearing cached data.
final class CacheManager: CacheManagerProtocol {
    private let cache = NSCache<NSString, CacheEntry>()
    private let fileMAnager = FileManager.default
    private var cacheDirectory: URL
    private let pathComponent = "DataFetcherCache"
    private let defaultExpirationTime: Double = 3600
    
    /// Creates a new CacheManager instance.
    ///
    /// This initializer sets up both the memory cache and disk cache directory.
    /// The memory cache is limited to 100 items and 50MB total size.
    /// The disk cache is created in the app's cache directory with iOS version compatibility.
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
    
    /// Stores data in both memory and disk cache.
    ///
    /// This method encodes the provided value to JSON data and stores it in both
    /// the memory cache (for fast access) and disk cache (for persistence).
    /// The data is stored with the specified expiration time or the default
    /// expiration time if none is provided.
    ///
    /// - Parameters:
    ///   - value: The encodable value to cache
    ///   - key: The cache key to use for storage
    ///   - expiration: Optional expiration time in seconds (uses default if nil)
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
    
    /// Removes cached data for the specified key from both memory and disk cache.
    ///
    /// - Parameter key: The cache key to remove
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
    
    /// Clears all cached data from both memory and disk cache.
    ///
    /// This method removes all entries from the memory cache and deletes all
    /// files from the disk cache directory.
    func clear() {
        cache.removeAllObjects()
        
        let contents = try? fileMAnager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
        contents?.forEach { try? fileMAnager.removeItem(at: $0) }
    }
}

/// Internal class representing a cache entry with data and expiration information.
///
/// This class encapsulates cached data along with its expiration date,
/// providing a simple way to check if the data is still valid.
private final class CacheEntry {
    let data: Data
    let expirationDate: Date
    
    /// Indicates whether the cache entry has expired.
    ///
    /// Returns `true` if the current date is after the expiration date.
    var isExpired: Bool {
        Date() > expirationDate
    }
    init(data: Data, expirationDate: Date) {
        self.data = data
        self.expirationDate = expirationDate
    }
}
