@testable import BraintreeCore
import Foundation

class MockClientAuthorization: ClientAuthorization {
    var type: AuthorizationType
    var configURL: URL
    var bearer: String
    var originalValue: String
    
    init(
        type: AuthorizationType = .clientToken,
        configURL: URL = URL(string: "https://example.com")!,
        bearer: String = "testBearer",
        originalValue: String = "originalValue"
    ) {
        self.type = type
        self.configURL = configURL
        self.bearer = bearer
        self.originalValue = originalValue
    }
}
