import Foundation

// MARK: - Weather API Models
public struct WeaterModel: Codable {
    public let id: String
    public let type: String
    public let properties: WeaterModelProperties

    public enum CodingKeys: String, CodingKey {
        case id, type, properties
    }
    
    public init(id: String, type: String, properties: WeaterModelProperties) {
        self.id = id
        self.type = type
        self.properties = properties
    }
}

public struct WeaterModelProperties: Codable {
    public let id: String
    public let type: String
    public let forecast: String

    public enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
        case forecast
    }
    
    public init(id: String, type: String, forecast: String) {
        self.id = id
        self.type = type
        self.forecast = forecast
    }
}

public struct ForecastModel: Codable {
    public let properties: ForecastProperties
    
    public init(properties: ForecastProperties) {
        self.properties = properties
    }
}

public struct ForecastProperties: Codable {
    public let periods: [Period]
    
    public init(periods: [Period]) {
        self.periods = periods
    }
}

public struct Period: Codable {
    public let name: String
    public let temperature: Int
    public let temperatureUnit: TemperatureUnit
    public let temperatureTrend: String
    public let icon: String
    public let shortForecast: ShortForecast
    
    public init(name: String, temperature: Int, temperatureUnit: TemperatureUnit, temperatureTrend: String, icon: String, shortForecast: ShortForecast) {
        self.name = name
        self.temperature = temperature
        self.temperatureUnit = temperatureUnit
        self.temperatureTrend = temperatureTrend
        self.icon = icon
        self.shortForecast = shortForecast
    }
}

public enum ShortForecast: String, Codable, CaseIterable {
    case mostlyClear = "Mostly Clear"
    case sunny = "Sunny"
    case partlyCloudy = "Partly Cloudy"
    case mostlySunny = "Mostly Sunny"
}

public enum TemperatureUnit: String, Codable, CaseIterable {
    case f = "F"
    case c = "C"
}
