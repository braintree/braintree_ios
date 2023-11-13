import Foundation

/// The interface types that the device supports for displaying specific challenge user interfaces within the 3D Secure challenge.
@objc public enum BTThreeDSecureUIType: Int {

    /// Native
    case native

    /// HTML
    case html

    /// Both
    case both
}
