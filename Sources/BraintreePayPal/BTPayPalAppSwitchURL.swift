import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

struct BTPayPalAppSwitchURL {
    
    // MARK: - Initializer

    func universalLinksURL(
        universalLinkURL: URL,
        token: String
    ) -> URL? {
        let queryParameters: [String: Any?] = [
            "token": token,
            "source": "braintree_sdk",
            "switch_initiated_time": UInt64(Date().timeIntervalSince1970 * 1000)
        ]
        
        var urlComponent = URLComponents(url: universalLinkURL, resolvingAgainstBaseURL: false)!
        urlComponent.percentEncodedQuery = BTURLUtils.queryString(from: queryParameters as NSDictionary)
        return urlComponent.url
    }
}
