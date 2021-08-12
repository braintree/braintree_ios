import Foundation

class AppSwitcher {

    static var openVenmoURL: URL?

    static var successURL: URL? {
        var successComponents = openVenmoURL
            .flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false)})?
            .queryItems?
            .first(where: { $0.name == "x-success" })?
            .value
            .flatMap({ URLComponents(string: $0) })

        successComponents?.queryItems = [
            URLQueryItem(name: "x-source", value: "Venmo"),
            URLQueryItem(name: "username", value: "@fake-venmo-username"),
            URLQueryItem(name: "paymentMethodNonce", value: "fake-venmo-account-nonce")
        ]

        return successComponents?.url
    }

    static var errorURL: URL? {
        var errorComponents = openVenmoURL
            .flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false)})?
            .queryItems?
            .first(where: { $0.name == "x-error" })?
            .value
            .flatMap({ URLComponents(string: $0) })

        errorComponents?.queryItems = [
            URLQueryItem(name: "errorMessage", value: "An error occurred during the Venmo flow"),
            URLQueryItem(name: "errorCode", value: "123")
        ]

        return errorComponents?.url
    }

    static var cancelURL: URL? {
        return openVenmoURL
            .flatMap({ URLComponents(url: $0, resolvingAgainstBaseURL: false)})?
            .queryItems?
            .first(where: { $0.name == "x-cancel" })?
            .value
            .flatMap({ URL(string: $0) })
    }

    // TODO: We can update this MockVenmo returnURL to include the `resource_id` to more closely mimic the VenmoContext Flow.
    // OPTION 1: We add another "SUCCESS-CONTEXT" type button which triggers the context flow,
    // this way we can easily test both.
    // OPTION 2: We just update the existing "SUCCESS" button URL.

}
