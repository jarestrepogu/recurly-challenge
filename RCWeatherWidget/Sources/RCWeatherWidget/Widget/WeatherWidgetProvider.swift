import WidgetKit
import SwiftUI

public struct WeatherWidgetProvider: TimelineProvider {
    public typealias Entry = WeatherWidgetEntry
    
    private let dataService: WeatherDataService
    
    public init(dataService: WeatherDataService = WeatherDataService()) {
        self.dataService = dataService
    }
    
    public func placeholder(in context: Context) -> WeatherWidgetEntry {
        WeatherWidgetEntry(date: Date())
    }

    public func getSnapshot(in context: Context, completion: @escaping (WeatherWidgetEntry) -> ()) {
        let entry = WeatherWidgetEntry(date: Date())
        completion(entry)
    }

    public func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherWidgetEntry>) -> ()) {
        Task { @MainActor in
            await dataService.loadPeriods()
            
            var entries: [WeatherWidgetEntry] = []
            
            if let period = dataService.periods.first {
                let entry = WeatherWidgetEntry(date: Date(), period: period, isUnavailable: false)
                entries.append(entry)
            } else {
                let entry = WeatherWidgetEntry(date: Date(), period: nil, isUnavailable: true)
                entries.append(entry)
            }
            
            let refreshPolicy: TimelineReloadPolicy = dataService.periods.isEmpty ? 
                .after(Date().addingTimeInterval(300)) : // Retry every 5 minutes when unavailable
                .after(Date().addingTimeInterval(1800))  // Refresh every 30 minutes when available
            
            let timeline = Timeline(entries: entries, policy: refreshPolicy)
            completion(timeline)
        }
    }
}
