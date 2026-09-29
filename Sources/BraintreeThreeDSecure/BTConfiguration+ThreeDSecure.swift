import Foundation
import BraintreeCore

extension BTConfiguration {

    /// JWT for use with initializing Cardinal 3DS framework
    var cardinalAuthenticationJWT: String? {
        json?["threeDSecure"]["cardinalAuthenticationJWT"].asString()
    }
}
