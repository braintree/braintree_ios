import SwiftUI

/// PayPal payment button style options
public enum BTPaymentButtonStyle {

    /// The primary PayPal button style
    case primaryPayPal

    /// The black PayPal or Venmo button style
    case black

    /// The white PayPal or Venmo button style
    case white

    /// Logo image in the payment
    var logoImage: ImageResource {
        switch self {
        case .primaryPayPal:
            return .payPalLogoBlack
        case .black:
            return .payPalLogoWhite
        case .white:
            return .payPalLogoBlack
        }
    }

    /// Background color of the payment button
    var backgroundColor: Color {
        switch self {
        case .primaryPayPal:
            return Color(red: 96 / 255, green: 205 / 255, blue: 255 / 255)
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
}
