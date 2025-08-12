import WidgetKit
import Foundation

public struct WeatherWidgetEntry: TimelineEntry {
    public let date: Date
    public var period: Period?
    public var isUnavailable: Bool
    
    public init(date: Date, period: Period? = nil, isUnavailable: Bool = false) {
        self.date = date
        self.period = period
        self.isUnavailable = isUnavailable
    }
}
