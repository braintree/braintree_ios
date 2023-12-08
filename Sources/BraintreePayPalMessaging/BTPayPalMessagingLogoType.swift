import Foundation
import PayPalMessages

/// Logo type option for a PayPal Message
public enum BTPayPalMessagingLogoType {

    /// PayPal logo positioned inline within the message
    case inline

    /// Primary logo including both the PayPal monogram and logo
    case primary

    /// Alternative logo including just the PayPal monogram
    case alternative

    /// "PayPal" as bold text inline with the message
    case none

    var logoTypeRawValue: PayPalMessageLogoType {
        switch self {
        case .inline:
            return .inline
        case .primary:
            return .primary
        case .alternative:
            return .alternative
        case .none:
            return .none
        }
    }
}

