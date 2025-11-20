import SwiftUI

/// Payment button style options
public enum BTPaymentButtonStyle {

    /// The primary PayPal button style
    case primaryPayPal

    /// The black PayPal or Venmo button style
    case black

    /// The white PayPal or Venmo button style
    case white

    /// Logo image in the payment
    var logoImage: String? {
        switch self {
        case .primaryPayPal:
            return "PayPalLogoBlack"
        case .black:
            return "PayPalLogoWhite"
        case .white:
            return "PayPalLogoBlack"
        }
    }

    /// Background color of the payment button
    var backgroundColor: Color {
        switch self {
        case .primaryPayPal:
            return Color(hex: "#60CDFF")
        case .black:
            return .black
        case .white:
            return .white
        }
    }

    /// Outline around the payment button
    var hasOutline: Bool {
        switch self {
        case .primaryPayPal:
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
        case .primaryPayPal:
            return Color(hex: "#3DB5FF")
        case .black:
            return Color(hex: "#696969")
        case .white:
            return Color(hex: "E9E9E9")
        }
    }
}
