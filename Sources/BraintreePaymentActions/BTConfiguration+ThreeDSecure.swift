import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

extension BTConfiguration {

    /// JWT for use with initializing Cardinal's 3DS framework.
    var cardinalAuthenticationJWT: String? {
        json?["threeDSecure"]["cardinalAuthenticationJWT"].asString()
    }
}
