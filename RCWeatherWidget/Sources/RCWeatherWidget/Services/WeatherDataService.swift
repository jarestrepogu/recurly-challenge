import Foundation
import RCNetworking
import Combine

@MainActor
public class WeatherDataService: ObservableObject {
    @Published public var isLoading: Bool = false
    @Published public var error: NetworkError?
    @Published public var progress: Double = 0.0
    @Published public var periods: [Period] = []
    
    private let chainBuilder = RequestChainBuilder()
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        // Bind chain builder properties to service
        chainBuilder.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        chainBuilder.$error
            .assign(to: \.error, on: self)
            .store(in: &cancellables)
        chainBuilder.$progress
            .assign(to: \.progress, on: self)
            .store(in: &cancellables)
    }
    
    public func loadPeriods(latitude: Double = 37.2883, longitude: Double = -121.8434) async {
        clearError()
        
        let firstConfig = chainBuilder.fetcher.configure {
            domain("api.weather.gov")
            path("/points/\(latitude),\(longitude)")
            method(.get)
            timeout(15.0)
        }
        
        if let secondResponse: ForecastModel = await chainBuilder.chainTwoRequest(
            first: firstConfig,
            then: { (weaterModel: WeaterModel) in
                let secondURL = weaterModel.properties.forecast
                
                guard let url = URL(string: secondURL),
                      let host = url.host(percentEncoded: true) else {
                    return self.chainBuilder.fetcher.configure {
                        domain("api.weather.gov")
                        method(.get)
                    }
                }
                
                return self.chainBuilder.fetcher.configure {
                    domain(host)
                    path(url.path(percentEncoded: true))
                    method(.get)
                    timeout(15.0)
                }
            }
        ) {
            self.periods = secondResponse.properties.periods
        } else {
            self.periods = []
        }
    }
    
    public func clearData() {
        periods = []
        clearError()
    }
    
    public func clearError() {
        chainBuilder.clearError()
    }
}

@MainActor
final class RequestChainBuilder: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var error: NetworkError?
    @Published var progress: Double = 0.0
    
    let fetcher = RecurlyDataFetcher()
    
    func chainTwoRequest<T: Decodable, U: Decodable>(first: RequestConfiguration, then: @escaping (T) -> RequestConfiguration) async -> U? {
        isLoading = true
        error = nil
        progress = 0.0
        
        defer {
            isLoading = false
            progress = 1.0
        }
        
        do {
            progress = 0.3
            let firstResult: T = try await fetcher.fetch(first)
            
            progress = 0.6
            let secondConfig = then(firstResult)
            
            progress = 0.8
            let secondResult: U = try await fetcher.fetch(secondConfig)
            return secondResult
        } catch {
            self.error = NetworkError.networkError(error)
            return nil
        }
    }
    
    func clearError() {
        self.error = nil
    }
}
