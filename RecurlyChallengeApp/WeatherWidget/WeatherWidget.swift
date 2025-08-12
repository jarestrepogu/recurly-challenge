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
        var entries: [ForecastEntry] = []
        Task { @MainActor in
            let viewModel = ViewModel()
            await viewModel.loadPeriods()
            let period = viewModel.periods.first
            let entry = ForecastEntry(date: Date(), period: period)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct ForecastEntry: TimelineEntry {
    let date: Date
    var period: Period?
}

struct WeatherWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: ForecastEntry

    var body: some View {
        switch family {
        case .systemSmall:
            RCWeatherWidgetSmall(temperature: entry.period?.temperature ?? 0, unit: entry.period?.temperatureUnit.rawValue ?? "-", shortForecast: entry.period?.shortForecast.rawValue ?? "")
        case .systemMedium:
            RCWeatherWidgetMedium(temperature: entry.period?.temperature ?? 0, unit: entry.period?.temperatureUnit.rawValue ?? "-", shortForecast: entry.period?.shortForecast.rawValue ?? "")
        case .systemLarge:
            RCWeatherWidgetLarge(temperature: entry.period?.temperature ?? 0, unit: entry.period?.temperatureUnit.rawValue ?? "-", shortForecast: entry.period?.shortForecast.rawValue ?? "")
        default:
            RCWeatherWidgetMedium(temperature: entry.period?.temperature ?? 0, unit: entry.period?.temperatureUnit.rawValue ?? "-", shortForecast: entry.period?.shortForecast.rawValue ?? "")
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
        }
        .configurationDisplayName("Forecast Widget")
        .description("This is a forecast widget for the Recurly Challenge!")
        .contentMarginsDisabled()
    }
}

#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    ForecastEntry(date: .now)
    ForecastEntry(date: .now)
}
