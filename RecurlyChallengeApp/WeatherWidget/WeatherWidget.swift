//
//  WeatherWidget.swift
//  WeatherWidget
//
//  Created by Jorge Restrepo on 8/08/25.
//

import WidgetKit
import SwiftUI
import RCWeatherWidget

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> ForecastEntry {
        ForecastEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (ForecastEntry) -> ()) {
        let entry = ForecastEntry(date: Date())
        completion(entry)
    }

func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    Task { @MainActor in
        let viewModel = ViewModel()
        await viewModel.loadPeriods()
        
        var entries: [ForecastEntry] = []
        
        // Simple check: if we have data, use it; otherwise show unavailable
        if let period = viewModel.periods.first {
            let entry = ForecastEntry(date: Date(), period: period, isUnavailable: false)
            entries.append(entry)
        } else {
            let entry = ForecastEntry(date: Date(), period: nil, isUnavailable: true)
            entries.append(entry)
        }
        
        // Retry more frequently when unavailable
        let refreshPolicy: TimelineReloadPolicy = viewModel.periods.isEmpty ? 
            .after(Date().addingTimeInterval(300)) : // Retry every 5 minutes when unavailable
            .after(Date().addingTimeInterval(1800))  // Refresh every 30 minutes when available
        
        let timeline = Timeline(entries: entries, policy: refreshPolicy)
        completion(timeline)
    }
}
}

struct ForecastEntry: TimelineEntry {
    let date: Date
    var period: Period?
    var isUnavailable: Bool
    
    init(date: Date, period: Period? = nil, isUnavailable: Bool = false) {
        self.date = date
        self.period = period
        self.isUnavailable = isUnavailable
    }
}

struct WeatherWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: ForecastEntry

    var body: some View {
        if entry.isUnavailable {
            // Simple unavailable state
            UnavailableWidgetView(family: family)
        } else if let period = entry.period {
            // Normal weather display
            WeatherContentWidgetView(period: period, family: family)
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
                temperature: entry.period.temperature,
                unit: entry.period.temperatureUnit.rawValue,
                shortForecast: entry.period.shortForecast.rawValue
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

struct WeatherWidget: Widget {
    let kind: String = "WeatherWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WeatherWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)  
            } else {
                WeatherWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
#elseif os(tvOS)
        WeatherWidgetEntryView(entry: entry)
            .padding()
            .background()
#endif
        }
        .configurationDisplayName("Forecast Widget")
        .description("This is a forecast widget for the Recurly Challenge!")
        .contentMarginsDisabled()
    }
}

#if os(iOS)
#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    ForecastEntry(date: .now)
    ForecastEntry(date: .now)
}
#elseif os(tvOS)
#Preview(as: .systemExtraLarge) {
    WeatherWidget()
} timeline: {
    ForecastEntry(date: .now)
    ForecastEntry(date: .now)
}
#endif
