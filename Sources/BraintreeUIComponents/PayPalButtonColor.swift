import SwiftUI

/// Payment button color  options
public enum PayPalButtonColor: PaymentButtonColorProtocol {

    /// The default PayPal button color
    case blue

    /// The black PayPal button color
    case black

    /// The white PayPal button color
    case white

    /// Logo image for the PayPal Button
    var logoImageName: String? {
        switch self {
        case .blue:
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
        case .blue:
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
            return Color(hex: "#3DB5FF")
        case .black:
            return Color(hex: "#696969")
        case .white:
            return Color(hex: "E9E9E9")
        }
    }
}
