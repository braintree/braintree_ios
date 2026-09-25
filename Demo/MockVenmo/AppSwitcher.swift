import Foundation

enum AppSwitcher {

    static var openVenmoURL: URL?

    static var successURLWithPaymentContext: URL? {
        let resourceID = "cGF5bWVudGNvbnRleHRfZGNwc3B5MmJyd2RqcjNxbiM4NjE4ZThkYi0xZDJkLTQwYjktYWJjOC0zNTVlNTk5YzliNTg="

        return returnURL(appendingPath: "success", queryItems: [URLQueryItem(name: "resource_id", value: resourceID)])
    }

    static var successURLWithoutPaymentContext: URL? {
        let username = "@fake-venmo-username"
        let nonce = "fake-venmo-account-nonce"

        return returnURL(appendingPath: "success", queryItems: [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "paymentMethodNonce", value: nonce)
        ])
    }

    static var errorURL: URL? {
        returnURL(appendingPath: "error", queryItems: [
            URLQueryItem(name: "errorMessage", value: "An error occurred during the Venmo flow"),
            URLQueryItem(name: "errorCode", value: "123")
        ])
    }

    static var cancelURL: URL? {
        returnURL(appendingPath: "cancel")
    }

    /// Builds the return URL using Demo's own `com.braintreepayments.Demo.payments` custom URL scheme rather
    /// than an `https` universal link. `BTVenmoAppSwitchReturnURL.isValid(url:)` accepts this form
    /// (`host == "x-callback-url"`, `path` prefixed with `/vzero/auth/venmo/`) because it mirrors how the real
    /// Venmo app returns control via a merchant's custom scheme. Universal links require Simulator to resolve
    /// them without going through Safari, which is unreliable in CI; a custom scheme open is delivered directly
    /// to `scene(_:openURLContexts:)` with no network dependency.
    private static func returnURL(appendingPath path: String, queryItems: [URLQueryItem] = []) -> URL? {
        var components = URLComponents()
        components.scheme = "com.braintreepayments.Demo.payments"
        components.host = "x-callback-url"
        components.path = "/vzero/auth/venmo/\(path)"

        guard !queryItems.isEmpty else {
            print("DEBUG - AppSwitcher returnURL: \(components.url?.absoluteString ?? "nil")")
            return components.url
        }
        components.queryItems = queryItems
        print("DEBUG - AppSwitcher returnURL: \(components.url?.absoluteString ?? "nil")")
        return components.url
    }
}
