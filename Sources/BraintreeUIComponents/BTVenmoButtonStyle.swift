import SwiftUI

/// Venmo payment button style options
public enum BTVenmoButtonStyle: PaymentButtonStyleProtocol {

    /// The blue Venmo button style (Venmo exclusive)
    case primaryVenmo

    /// The black Venmo button style
    case black

    /// The white Venmo button style
    case white

    /// Logo image for the Venmo button
    public var logoImage: ImageResource? {
        switch self {
        case .primaryVenmo:
            return .venmoLogoWhite
        case .black:
            return .venmoLogoWhite
        case .white:
            return .venmoLogoBlue
        }
    }

    /// Background color of the Venmo button
    public var backgroundColor: Color {
        switch self {
        case .primaryVenmo:
            return Color(hex: "#008CFF")
        case .black:
            return .black
        case .white:
            return .white
        }
    }

    /// Outline around the Venmo button
    public var hasOutline: Bool {
        switch self {
        case .primaryVenmo:
            return false
        case .black:
            return false
        case .white:
            return true
        }
    }
    
    /// Minimum width for Venmo logo with proper padding
    public var minimumWidth: CGFloat {
        return 166
    }
}
