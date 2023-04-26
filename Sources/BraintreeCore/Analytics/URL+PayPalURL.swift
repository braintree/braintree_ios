import Foundation

extension URL {
    
    /// Used to determine if a the URL is a paypal.com domain in order to format API requests accordingly
    var isPayPalURL: Bool {
        return self.absoluteString.contains("paypal.com")
    }
}
