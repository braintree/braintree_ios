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

    /// Appends a path component (e.g. "success"/"error"/"cancel") before any existing query string on
    /// `openVenmoURL`, rather than concatenating strings, so the app-switch return URL's path still
    /// contains the expected keyword when `openVenmoURL` already has query parameters.
    private static func returnURL(appendingPath path: String, queryItems: [URLQueryItem] = []) -> URL? {
        guard let baseURL = openVenmoURL else { return nil }
        let urlWithPath = baseURL.appendingPathComponent(path)

        guard !queryItems.isEmpty else { return urlWithPath }
        guard var components = URLComponents(url: urlWithPath, resolvingAgainstBaseURL: false) else { return urlWithPath }
        components.queryItems = (components.queryItems ?? []) + queryItems
        return components.url
    }
}
