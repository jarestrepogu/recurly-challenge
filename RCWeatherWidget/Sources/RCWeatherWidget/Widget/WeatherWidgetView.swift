import SwiftUI
import WidgetKit

public struct WeatherWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    public var entry: WeatherWidgetEntry

    public init(entry: WeatherWidgetEntry) {
        self.entry = entry
    }

    public var body: some View {
        if entry.isUnavailable {
            UnavailableWidgetView(family: family)
        } else {
            WeatherContentWidgetView(period: entry.period!, family: family)
        }
    }
}

struct UnavailableWidgetView: View {
    let family: WidgetFamily
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
            VStack(spacing: 4) {
                Image(systemName: "cloud.slash")
                    .font(.system(size: family == .systemSmall ? 20 : 28))
                    .foregroundColor(.secondary)
                Text("Unavailable")
                    .font(.system(size: family == .systemSmall ? 12 : 16, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct WeatherContentWidgetView: View {
    let period: Period
    let family: WidgetFamily
    
    var body: some View {
        switch family {
        case .systemSmall:
            RCWeatherWidgetSmall(
                temperature: period.temperature, 
                unit: period.temperatureUnit.rawValue, 
                shortForecast: period.shortForecast.rawValue
            )
        case .systemMedium:
            RCWeatherWidgetMedium(
                temperature: period.temperature, 
                unit: period.temperatureUnit.rawValue, 
                shortForecast: period.shortForecast.rawValue
            )
        case .systemLarge:
            RCWeatherWidgetLarge(
                temperature: period.temperature, 
                unit: period.temperatureUnit.rawValue, 
                shortForecast: period.shortForecast.rawValue
            )
        #if os(tvOS)
        case .systemExtraLarge:
            RCWeatherWidgetExtraLarge(
                temperature: period.temperature, 
                unit: period.temperatureUnit.rawValue, 
                shortForecast: period.shortForecast.rawValue
            )
        #endif
        default:
            RCWeatherWidgetMedium(
                temperature: period.temperature, 
                unit: period.temperatureUnit.rawValue, 
                shortForecast: period.shortForecast.rawValue
            )
        }
    }
}
