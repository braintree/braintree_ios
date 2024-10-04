import Foundation

enum AppSwitcher {

    static var openVenmoURL: URL?

    static var successURLWithPaymentContext: URL? {
        var successComponents = openVenmoURL
            .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?
            .queryItems?
            .first { $0.name == "x-success" }?
            .value
            .flatMap { URLComponents(string: $0) }

        successComponents?.queryItems = [
            URLQueryItem(name: "x-source", value: "Venmo"),
            URLQueryItem(
                name: "resource_id",
                value: "cGF5bWVudGNvbnRleHRfZGNwc3B5MmJyd2RqcjNxbiM4NjE4ZThkYi0xZDJkLTQwYjktYWJjOC0zNTVlNTk5YzliNTg="
            )
        ]

        return successComponents?.url
    }

    static var successURLWithoutPaymentContext: URL? {
        var successComponents = openVenmoURL
            .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?
            .queryItems?
            .first { $0.name == "x-success" }?
            .value
            .flatMap { URLComponents(string: $0) }

        successComponents?.queryItems = [
            URLQueryItem(name: "x-source", value: "Venmo"),
            URLQueryItem(name: "username", value: "@fake-venmo-username"),
            URLQueryItem(name: "paymentMethodNonce", value: "fake-venmo-account-nonce")
        ]

        return successComponents?.url
    }

    static var errorURL: URL? {
        var errorComponents = openVenmoURL
            .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?
            .queryItems?
            .first { $0.name == "x-error" }?
            .value
            .flatMap { URLComponents(string: $0) }

        errorComponents?.queryItems = [
            URLQueryItem(name: "errorMessage", value: "An error occurred during the Venmo flow"),
            URLQueryItem(name: "errorCode", value: "123")
        ]

        return errorComponents?.url
    }

    static var cancelURL: URL? {
        return openVenmoURL
            .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?
            .queryItems?
            .first { $0.name == "x-cancel" }?
            .value
            .flatMap { URL(string: $0) }
    }
}
