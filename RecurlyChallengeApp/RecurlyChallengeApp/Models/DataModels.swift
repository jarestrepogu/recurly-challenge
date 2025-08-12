//
//  DataModels.swift
//  RecurlyChallengeApp
//
//  Created by Jorge Restrepo on 7/08/25.
//

import Foundation

struct WeaterModel: Codable {
    let id: String
    let type: String
    let properties: WeaterModelProperties

    enum CodingKeys: String, CodingKey {
        case id, type, properties
    }
}

// MARK: - WeaterModelProperties
struct WeaterModelProperties: Codable {
    let id: String
    let type: String
    let forecast: String

    enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
        case forecast
    }
}

// MARK: - Forecast
struct ForecastModel: Codable {
    let properties: ForecastProperties
}

// MARK: - Properties
struct ForecastProperties: Codable {
    let periods: [Period]
}

// MARK: - Period
struct Period: Codable {
    let name: String
    let temperature: Int
    let temperatureUnit: TemperatureUnit
    let temperatureTrend: String
    let icon: String // image url
    let shortForecast: ShortForecast
}

enum ShortForecast: String, Codable {
    case mostlyClear = "Mostly Clear"
    case sunny = "Sunny"
    case partlyCloudy = "Partly Cloudy"
    case mostlySunny = "Mostly Sunny"
}

enum TemperatureUnit: String, Codable {
    case f = "F"
}
