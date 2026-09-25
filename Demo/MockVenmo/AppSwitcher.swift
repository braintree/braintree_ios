import Foundation

enum AppSwitcher {

    static var openVenmoURL: URL?

    static var successURLWithPaymentContext: URL? {
        let resourceID = "cGF5bWVudGNvbnRleHRfZGNwc3B5MmJyd2RqcjNxbiM4NjE4ZThkYi0xZDJkLTQwYjktYWJjOC0zNTVlNTk5YzliNTg="

        return returnURL(forQueryItemNamed: "x-success", additionalQueryItems: [URLQueryItem(name: "resource_id", value: resourceID)])
    }

    static var successURLWithoutPaymentContext: URL? {
        let username = "@fake-venmo-username"
        let nonce = "fake-venmo-account-nonce"

        return returnURL(forQueryItemNamed: "x-success", additionalQueryItems: [
            URLQueryItem(name: "username", value: username),
            URLQueryItem(name: "paymentMethodNonce", value: nonce)
        ])
    }

    static var errorURL: URL? {
        returnURL(forQueryItemNamed: "x-error", additionalQueryItems: [
            URLQueryItem(name: "errorMessage", value: "An error occurred during the Venmo flow"),
            URLQueryItem(name: "errorCode", value: "123")
        ])
    }

    static var cancelURL: URL? {
        returnURL(forQueryItemNamed: "x-cancel")
    }

    /// `openVenmoURL` is the outbound `https://venmo.com/go/checkout` universal link the Demo app opened to
    /// switch into Venmo — it is not a domain associated with the Demo app. The actual URL Venmo should
    /// redirect back to is embedded in that link's `x-success`/`x-error`/`x-cancel` query parameters, so the
    /// return URL must be extracted from there rather than built by appending onto `openVenmoURL` itself.
    private static func returnURL(forQueryItemNamed queryItemName: String, additionalQueryItems: [URLQueryItem] = []) -> URL? {
        guard
            let openVenmoURL,
            let openComponents = URLComponents(url: openVenmoURL, resolvingAgainstBaseURL: false),
            let baseReturnURLString = openComponents.queryItems?.first(where: { $0.name == queryItemName })?.value,
            let baseReturnURL = URL(string: baseReturnURLString)
        else {
            print("DEBUG - AppSwitcher failed to extract \(queryItemName) from openVenmoURL: \(openVenmoURL?.absoluteString ?? "nil")")
            return nil
        }

        guard !additionalQueryItems.isEmpty else {
            print("DEBUG - AppSwitcher returnURL (no additional query items): \(baseReturnURL.absoluteString)")
            return baseReturnURL
        }
        guard var components = URLComponents(url: baseReturnURL, resolvingAgainstBaseURL: false) else { return baseReturnURL }
        components.queryItems = (components.queryItems ?? []) + additionalQueryItems
        print("DEBUG - AppSwitcher returnURL: \(components.url?.absoluteString ?? "nil")")
        return components.url
    }
}
