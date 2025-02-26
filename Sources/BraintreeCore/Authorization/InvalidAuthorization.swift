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
  
        // TODO: consider reworking this protocol logic in a future version
        // swiftlint:disable force_unwrapping
        /// This URL is never used in the SDK as we always return an error if the authorization type is `.invalidAuthorization`
        /// before construting or using the `configURL` in any way. This URL is currently required per the protocol.
        self.configURL = URL(string: "https://paypal.com")!
    }
}
