import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Information pertaining to the regulatory environment for a credit card if authentication insight is requested during tokenization.
@objcMembers public class BTAuthenticationInsight: NSObject {

    // MARK: - Public Properties

    /// The regulation environment for the associated nonce to help determine the need for 3D Secure.
    /// See https://developer.paypal.com/braintree/docs/guides/3d-secure/advanced-options/ios/v5#authentication-insight
    /// for a list of possible values.
    public var regulationEnvironment: String?

    // MARK: - Initializer

    init(json: BTJSON) {
        if let customerAuthRegulationEnvironment = json["customerAuthenticationRegulationEnvironment"].asString() {
            self.regulationEnvironment = customerAuthRegulationEnvironment
        } else if let regulationEnvironment = json["regulationEnvironment"].asString() {
            self.regulationEnvironment = regulationEnvironment
        }

        // GraphQL returns "PSDTWO" instead of "psd2"
        if regulationEnvironment == "PSDTWO" {
            self.regulationEnvironment = "psd2"
        }

        if let regulationEnvironment {
            self.regulationEnvironment = regulationEnvironment.lowercased()
        }
    }
}
