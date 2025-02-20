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
        self.configURL = URL(string: "https://example.com")!
    }
}
