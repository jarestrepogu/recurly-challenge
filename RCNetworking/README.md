# RCNetworking

A SwiftUI-friendly networking library for iOS 15+ that provides a clean, type-safe API for making HTTP requests with optional caching support, created as part of the iOS/tvOS Take Home Coding Challenge by Recurly.

## Features

- 🚀 **Simple API**: Easy-to-use result builder pattern for request configuration
- 💾 **Automatic Caching**: Built-in memory and disk caching with configurable policies
- 🔒 **Type Safety**: Full Swift type safety with Codable support
- ⚡ **Async/Await**: Modern concurrency support
- 🛡️ **Error Handling**: Comprehensive error types with localized descriptions
- 📱 **iOS 15+ Support**: Targets iOS 15 and later

## Quick Start

### Basic Usage

```swift
import RCNetworking

// Create a data fetcher
let fetcher = RecurlyDataFetcher()

// Configure a request using the builder pattern
let config = fetcher.configure {
    domain("api.example.com")
    path("/users")
    method(.get)
    headers(["Authorization": "Bearer your-token"])
}

// Make a request
do {
    let users: [User] = try await fetcher.fetch(config)
    print("Fetched \(users.count) users")
} catch {
    print("Error: \(error)")
}
```

### Cached Requests

```swift
// Configure a request with caching
let config = fetcher.configure {
    domain("api.example.com")
    path("/weather")
    method(.get)
    cachePolicy(.custom(expiration: 1800)) // Cache for 30 minutes
}

// Fetch with automatic caching
do {
    let weather: Weather = try await fetcher.fetchWithCache(config)
    print("Weather: \(weather)")
} catch {
    print("Error: \(error)")
}
```

### POST Request with JSON Body

```swift
// Create a user object
let newUser = User(name: "John Doe", email: "john@example.com")

// Configure POST request
let config = fetcher.configure {
    domain("api.example.com")
    path("/users")
    method(.post)
    headers(["Content-Type": "application/json"])
    body(try! JSONEncoder().encode(newUser))
}

// Make the request
do {
    let createdUser: User = try await fetcher.fetch(config)
    print("Created user: \(createdUser)")
} catch {
    print("Error: \(error)")
}
```

### Query Parameters

```swift
let config = fetcher.configure {
    domain("api.example.com")
    path("/search")
    method(.get)
    queryParameters([
        "q": "swift programming",
        "page": "1",
        "limit": "20"
    ])
}

do {
    let results: SearchResults = try await fetcher.fetch(config)
    print("Found \(results.count) results")
} catch {
    print("Error: \(error)")
}
```

## Cache Policies

The library supports several cache policies:

- `.default`: Uses default expiration (1 hour)
- `.reloadIgnoringCache`: Always fetches fresh data
- `.returnCacheDataElseLoad`: Returns cached data if available, otherwise fetches fresh data
- `.returnCacheDataDontLoad`: Returns cached data only, never makes network requests
- `.custom(expiration:)`: Uses a custom expiration time

```swift
let config = fetcher.configure {
    domain("api.example.com")
    path("/data")
    method(.get)
    cachePolicy(.custom(expiration: 3600)) // Cache for 1 hour
}
```

## Error Handling

The library provides comprehensive error handling with `NetworkError`:

```swift
do {
    let data: MyData = try await fetcher.fetch(config)
} catch NetworkError.invalidURL {
    print("Invalid URL configuration")
} catch NetworkError.serverError(let statusCode) {
    print("Server error with status code: \(statusCode)")
} catch NetworkError.timeout {
    print("Request timed out")
} catch NetworkError.networkError(let underlyingError) {
    print("Network error: \(underlyingError)")
} catch {
    print("Unexpected error: \(error)")
}
```

## Advanced Usage

### Custom Timeout

```swift
let config = fetcher.configure {
    domain("api.example.com")
    path("/slow-endpoint")
    method(.get)
    timeout(60.0) // 60 second timeout
}
```

### Complex Request Configuration

```swift
let config = fetcher.configure {
    domain("api.example.com")
    path("/users/123/posts")
    method(.get)
    queryParameters([
        "include": "comments,author",
        "sort": "created_at",
        "order": "desc"
    ])
    headers([
        "Authorization": "Bearer \(token)",
        "Accept": "application/json",
        "X-API-Version": "2.0"
    ])
    cachePolicy(.custom(expiration: 900)) // 15 minutes
    timeout(30.0)
}
```

## Requirements

- iOS 15.0+
- Swift 6.1+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add the following dependency to your `Package.swift`:

```swift
dependencies: [
    .package(url: "path/to/RCNetworking", from: "1.0.0")
]
```

Or add it directly in Xcode:
1. File → Add Package Dependencies
2. Enter the package URL
3. Select the version and add to your target

## Architecture

The library is built with a clean architecture pattern:

- **RecurlyDataFetcher**: Main public interface
- **DataFetcher**: Core networking logic with caching
- **NetworkClient**: Low-level HTTP client
- **CacheManager**: Memory and disk caching
- **RequestConfiguration**: Request configuration model
- **RequestConfigurationBuilder**: Result builder for fluent API

## License

This project is licensed under the MIT License.