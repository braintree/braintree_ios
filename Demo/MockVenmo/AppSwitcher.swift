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
    ///
    /// `openVenmoURL` is set to a fixed placeholder URL by SceneDelegate's `willConnectTo`, not extracted
    /// from a real inbound app-switch: the UI tests activate MockVenmo directly via
    /// `XCUIApplication(bundleIdentifier:).activate()` rather than going through a genuine OS-level
    /// universal link/URL scheme handoff, so it never carries real x-success/x-error/x-cancel query items.
    private static func returnURL(appendingPath path: String, queryItems: [URLQueryItem] = []) -> URL? {
        guard let baseURL = openVenmoURL else {
            print("DEBUG - AppSwitcher returnURL(appendingPath: \(path)) failed: openVenmoURL is nil")
            return nil
        }
        let urlWithPath = baseURL.appendingPathComponent(path)

        guard !queryItems.isEmpty else {
            print("DEBUG - AppSwitcher returnURL: \(urlWithPath.absoluteString)")
            return urlWithPath
        }
        guard var components = URLComponents(url: urlWithPath, resolvingAgainstBaseURL: false) else { return urlWithPath }
        components.queryItems = (components.queryItems ?? []) + queryItems
        print("DEBUG - AppSwitcher returnURL: \(components.url?.absoluteString ?? "nil")")
        return components.url
    }
}
