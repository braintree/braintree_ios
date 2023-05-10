import Foundation

extension URL {
    
    /// Used to determine if a the URL is a paypal.com domain in order to format API requests accordingly
    var isPayPalURL: Bool {
        absoluteString.contains("api-m.paypal.com")
    }
}
