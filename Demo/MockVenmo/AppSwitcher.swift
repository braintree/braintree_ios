import Foundation

enum AppSwitcher {

    static var openVenmoURL: URL?

    static var successURLWithPaymentContext: URL? {
        let resourceID = "cGF5bWVudGNvbnRleHRfZGNwc3B5MmJyd2RqcjNxbiM4NjE4ZThkYi0xZDJkLTQwYjktYWJjOC0zNTVlNTk5YzliNTg="
        
        return URL(string: "\(openVenmoURL?.absoluteString ?? "")/success?resource_id=\(resourceID)")
    }

    static var successURLWithoutPaymentContext: URL? {
        let username = "@fake-venmo-username"
        let nonce = "fake-venmo-account-nonce"
        
        return URL(string: "\(openVenmoURL?.absoluteString ?? "")/success?username=\(username)&paymentMethodNonce=\(nonce)")
    }

    static var errorURL: URL? {
        URL(string: "\(openVenmoURL?.absoluteString ?? "")/error?errorMessage=An error occurred during the Venmo flow&errorCode=123")
    }

    static var cancelURL: URL? {
        URL(string: "\(openVenmoURL?.absoluteString ?? "")/cancel")
    }
}
