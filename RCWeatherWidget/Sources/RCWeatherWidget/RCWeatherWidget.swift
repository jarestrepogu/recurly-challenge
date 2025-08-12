// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI

public struct RCWeatherWidgetSmall: View {
    let temperature: Int
    let unit: String
    let shortForecast: String
    
    public init(temperature: Int, unit: String, shortForecast: String) {
        self.temperature = temperature
        self.unit = unit
        self.shortForecast = shortForecast
    }
    
    @ViewBuilder
    public var body: some View {
        ZStack {
            Color(.systemBlue)
                .opacity(0.25)
            Image(systemName: "cloud.sun")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.08)
            VStack(alignment: .leading,spacing: .zero) {
                HStack(spacing: 4) {
                    Text(temperature.toString)
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                    Text("º\(unit)")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                }
                Text(shortForecast)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
        }
    }
}

public struct RCWeatherWidgetMedium: View {
    let temperature: Int
    let unit: String
    let shortForecast: String
    
    public init(temperature: Int, unit: String, shortForecast: String) {
        self.temperature = temperature
        self.unit = unit
        self.shortForecast = shortForecast
    }
    
    @ViewBuilder
    public var body: some View {
        ZStack {
            Color(.systemBlue)
                .opacity(0.25)
            HStack(alignment: .top, spacing: 16) {
                HStack(spacing: 4) {
                    Text(temperature.toString)
                        .font(.system(size: 90))
                        .fontWeight(.semibold)
                    Text("º\(unit)")
                        .font(.system(size: 90))
                        .fontWeight(.semibold)
                }
                VStack(alignment: .center, spacing: .zero) {
                    Image(systemName: "cloud.sun")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 80, height: 80)
                        .opacity(0.8)
                    Text(shortForecast)
                        .font(.title)
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

public struct RCWeatherWidgetLarge: View {
    let temperature: Int
    let unit: String
    let shortForecast: String
    
    public init(temperature: Int, unit: String, shortForecast: String) {
        self.temperature = temperature
        self.unit = unit
        self.shortForecast = shortForecast
    }
    
    @ViewBuilder
    public var body: some View {
        ZStack {
            Color(.systemBlue)
                .opacity(0.25)
            VStack(alignment: .center, spacing: .zero) {
                Image(systemName: "cloud.sun")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 240, height: 240)
                    .opacity(0.8)
                Text("\(temperature.toString) º\(unit)  \(shortForecast)")
                        .font(.system(size: 90))
                        .fontWeight(.semibold)
                        .minimumScaleFactor(0.6)
                        .padding()
            }
        }
    }
}

#if os(tvOS)
public struct RCWeatherWidgetExtraLarge: View {
    let temperature: Int
    let unit: String
    let shortForecast: String
    
    public init(temperature: Int, unit: String, shortForecast: String) {
        self.temperature = temperature
        self.unit = unit
        self.shortForecast = shortForecast
    }
    
    @ViewBuilder
    public var body: some View {
        ZStack {
            Color(.systemBlue)
                .opacity(0.25)
            VStack(alignment: .center, spacing: 16) {
                Image(systemName: "cloud.sun")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .opacity(0.8)
                
                HStack(spacing: 8) {
                    Text(temperature.toString)
                        .font(.system(size: 120))
                        .fontWeight(.bold)
                    Text("º\(unit)")
                        .font(.system(size: 120))
                        .fontWeight(.bold)
                }
                
                Text(shortForecast)
                    .font(.system(size: 32))
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
            }
        }
    }
}
#endif

#Preview {
    RCWeatherWidgetSmall(temperature: 80, unit: "F", shortForecast: "Sunny")
}

extension Int {
    var toString: String {
        String(self)
    }
}
