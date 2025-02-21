import Foundation

/// An invalid authorization type
class InvalidAuthorization: ClientAuthorization {
    
    let type = AuthorizationType.invalidAuthorization
    let configURL: URL
    let bearer: String
    let originalValue: String
    
    init(_ rawValue: String) {
        self.bearer = rawValue
        self.originalValue = rawValue
        
        // swiftlint:disable:next force_unwrapping
        /// This URL is never used in the SDK as we always return an error if the authorization type is `.invalidAuthorization`
        /// before construting or using the `configURL` in any way
        self.configURL = URL(string: "https://paypal.com")!
    }
}
