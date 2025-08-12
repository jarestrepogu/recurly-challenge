import WidgetKit
import SwiftUI

public struct WeatherWidget: Widget {
    public let kind: String
    private let dataService: WeatherDataService
    
    public init(kind: String = "WeatherWidget", dataService: WeatherDataService = WeatherDataService()) {
        self.kind = kind
        self.dataService = dataService
    }

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherWidgetProvider(dataService: dataService)) { entry in
            #if os(iOS)
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
        .configurationDisplayName("Weather Forecast")
        .description("Shows current weather conditions")
        .contentMarginsDisabled()
    }
}

#if DEBUG
#Preview(as: .systemSmall) {
    WeatherWidget()
} timeline: {
    WeatherWidgetEntry(date: .now, period: nil, isUnavailable: true)
    WeatherWidgetEntry(date: .now, period: nil, isUnavailable: false)
}
#endif
