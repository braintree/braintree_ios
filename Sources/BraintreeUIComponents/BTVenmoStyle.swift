import SwiftUI

/// Venmo payment button style options
public enum BTVenmoButtonStyle {

    /// The blue Venmo button style (Venmo exclusive)
    case blue

    /// The black Venmo button style
    case black

    /// The white Venmo button style
    case white

    /// Logo image for the Venmo button
    var logoImage: ImageResource {
        switch self {
        case .blue:
            return .venmoLogoWhite
        case .black:
            return .venmoLogoWhite
        case .white:
            return .venmoLogoBlue
        }
    }

    /// Background color of the Venmo button
    var backgroundColor: Color {
        switch self {
        case .blue:
            return Color(red: 0 / 255, green: 140 / 255, blue: 255 / 255)
        case .black:
            return .black
        case .white:
            return .white
        }
    }

    /// Outline around the Venmo button
    var hasOutline: Bool {
        switch self {
        case .blue:
            return false
        case .black:
            return false
        case .white:
            return true
        }
    }
}
