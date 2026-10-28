import Foundation
import CardinalMobile

/// The interface types that the device supports for displaying specific challenge user interfaces
/// within the 3D Secure challenge.
///
/// Deliberately duplicated from `BraintreeThreeDSecure`'s identical `BTThreeDSecureUIType` rather than
/// shared, so this module's only dependency is the `CardinalMobile` binary — not the existing
/// `BraintreeThreeDSecure` module — keeping the M4 drive path fully isolated from the existing 3DS flow.
@objc public enum BTThreeDSecureLaunchUIType: Int {

    /// Native
    case native

    /// HTML
    case html

    /// Both
    case both

    var cardinalValue: CardinalSessionUIType {
        switch self {
        case .native:
            return .native
        case .html:
            return .HTML
        case .both:
            return .both
        }
    }
}
