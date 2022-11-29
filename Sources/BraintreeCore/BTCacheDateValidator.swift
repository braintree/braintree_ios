import Foundation

struct BTCacheDateValidator {

    let timeToLiveMinutes: Double = 5
    let dateFormatter: DateFormatter = DateFormatter()

    func isCacheInvalid(_ cachedConfigurationResponse: CachedURLResponse?) -> Bool {
        dateFormatter.dateFormat = "EEE',' dd' 'MMM' 'yyyy HH':'mm':'ss zzz"

        // Invalidate cached configuration after 5 minutes
        let expirationTimestamp: Date = Date().addingTimeInterval(-60 * timeToLiveMinutes)

        guard let cachedResponse = cachedConfigurationResponse?.response as? HTTPURLResponse,
              let cachedResponseDateString = cachedResponse.value(forHTTPHeaderField: "Date"),
              let cachedResponseTimestamp: Date = dateFormatter.date(from: cachedResponseDateString)
        else {
            return true
        }

        let earlierDate: Date = cachedResponseTimestamp <= expirationTimestamp ? cachedResponseTimestamp : expirationTimestamp

        return earlierDate == cachedResponseTimestamp
    }
}
