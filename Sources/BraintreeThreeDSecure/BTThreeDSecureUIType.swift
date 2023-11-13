import Foundation
import CardinalMobile

/// The interface types that the device supports for displaying specific challenge user interfaces within the 3D Secure challenge.
@objc public enum BTThreeDSecureUIType: Int {

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
