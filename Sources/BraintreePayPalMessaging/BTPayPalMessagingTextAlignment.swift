import Foundation
import PayPalMessages

/// Text alignment option for a PayPal Message
/// - Warning: This module is in beta. It's public API may change or be removed in future releases.
public enum BTPayPalMessagingTextAlignment {

    /// Text aligned to the left
    case left

    /// Text aligned to the center
    case center

    /// Text aligned to the right
    case right

    var textAlignmentRawValue: PayPalMessageTextAlign {
        switch self {
        case .left:
            return .left
        case .center:
            return .center
        case .right:
            return .right
        }
    }
}
