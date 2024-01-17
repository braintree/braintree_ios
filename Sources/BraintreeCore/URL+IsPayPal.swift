import Foundation

extension URL {
    
    /// Used to determine if the URL is a paypal.com domain in order to format API requests accordingly
    var isPayPalURL: Bool {
        absoluteString.contains("api.paypal.com") || absoluteString.contains("api.sandbox.paypal.com")
    }
}
