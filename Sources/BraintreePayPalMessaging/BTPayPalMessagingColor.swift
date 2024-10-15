import Foundation
import PayPalMessages

/// Text and logo color option for a PayPal Message
/// - Warning: This module is in beta. It's public API may change or be removed in future releases.
public enum BTPayPalMessagingColor {

    /// Black text with a color logo
    case black

    /// White text with a white logo
    case white

    /// Black text with a black logo
    case monochrome

    /// Black text with a desaturated logo
    case grayscale

    var messageColorRawValue: PayPalMessageColor {
        switch self {
        case .black:
            return .black
        case .white:
            return .white
        case .monochrome:
            return .monochrome
        case .grayscale:
            return .grayscale
        }
    }
}
