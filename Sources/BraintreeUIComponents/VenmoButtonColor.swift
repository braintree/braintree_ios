import SwiftUI

/// Venmo payment button style options
public enum VenmoButtonColor: PaymentButtonColorProtocol {

    /// The blue Venmo button style (Venmo exclusive)
    case primary

    /// The black Venmo button style
    case black

    /// The white Venmo button style
    case white

    /// Logo image name for Venmo button
    var logoImageName: String? {
        switch self {
        case .primary:
            return "VenmoLogoWhite"
        case .black:
            return "VenmoLogoWhite"
        case .white:
            return "VenmoLogoBlue"
        }
    }

    /// Background color of the Venmo button
    var backgroundColor: Color {
        switch self {
        case .primary:
            return Color(hex: "#008CFF")
        case .black:
            return .black
        case .white:
            return .white
        }
    }

    /// Outline around the Venmo button
    var hasOutline: Bool {
        switch self {
        case .primary:
            return false
        case .black:
            return false
        case .white:
            return true
        }
    }
}
