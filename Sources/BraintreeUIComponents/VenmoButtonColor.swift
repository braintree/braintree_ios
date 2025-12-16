import SwiftUI

/// Venmo payment button style options
public enum VenmoButtonColor: PaymentButtonColorProtocol {

    /// The blue Venmo button style (Venmo exclusive)
    case blue

    /// The black Venmo button style
    case black

    /// The white Venmo button style
    case white

    /// Logo image name for Venmo button
    var logoImageName: String? {
        switch self {
        case .blue:
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
        case .blue:
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
        case .blue:
            return false
        case .black:
            return false
        case .white:
            return true
        }
    }

    /// Background color when button is tapped
    var tappedButtonColor: Color {
        switch self {
        case .blue:
            return Color(hex: "#0074FF")
        case .black:
            return Color(hex: "#696969")
        case .white:
            return Color(hex: "#E9E9E9")
        }
    }

    /// Spinner color when button is tapped
    var spinnerColor: String? {
        switch self {
        case .blue:
            return "SpinnerBlack"
        case .black:
            return "SpinnerWhite"
        case .white:
            return "SpinnerBlack"
        }
    }
}
