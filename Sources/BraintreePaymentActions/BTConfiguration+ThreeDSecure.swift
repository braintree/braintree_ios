import Foundation

#if canImport(BraintreeCore)
import BraintreeCore
#endif

/// Deliberately duplicated from `BraintreeThreeDSecure`'s identical extension rather than shared,
/// so this module's only dependency is the `CardinalMobile` binary — not the legacy
/// `BraintreeThreeDSecure` module — keeping the M4 drive path fully isolated from the legacy 3DS flow.
extension BTConfiguration {

    /// JWT for use with initializing Cardinal's 3DS framework.
    var cardinalAuthenticationJWT: String? {
        json?["threeDSecure"]["cardinalAuthenticationJWT"].asString()
    }
}
