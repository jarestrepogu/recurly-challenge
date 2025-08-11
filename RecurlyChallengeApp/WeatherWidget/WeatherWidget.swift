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

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for dayOffset in 0 ..< 7 {
            let entryDate = Calendar.current.date(byAdding: .day, value: dayOffset, to: currentDate)!
            let startOfDay = Calendar.current.startOfDay(for: entryDate)
            let entry = ForecastEntry(date: startOfDay)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

//    func relevances() async -> WidgetRelevances<Void> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct ForecastEntry: TimelineEntry {
    let date: Date
}

struct WeatherWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            RCWeatherWidgetSmall(temperature: 80, unit: "F", shortForecast: "Sunny")
        case .systemMedium:
            RCWeatherWidgetMedium(temperature: 80, unit: "F", shortForecast: "Sunny")
        case .systemLarge:
            RCWeatherWidgetLarge(temperature: 80, unit: "F", shortForecast: "Sunny")
        default:
            RCWeatherWidgetMedium(temperature: 80, unit: "F", shortForecast: "Sunny")
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
