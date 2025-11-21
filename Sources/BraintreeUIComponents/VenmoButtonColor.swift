import SwiftUI

/// Protocol for payment button color and styling logic
protocol PaymentButtonColorProtocol {
    /// Logo image name for the button
    var logoImageName: String? { get }

    /// Background color of the button
    var backgroundColor: Color { get }

    /// Whether the button should have an outline
    var hasOutline: Bool { get }

    /// Background color when button is tapped
    var tappedButtonColor: Color { get }
}

/// Venmo payment button style options
public enum VenmoButtonColor: PaymentButtonColorProtocol {

    /// The blue Venmo button style (Venmo exclusive)
    case primary

    /// The black Venmo button style
    case black

    /// The white Venmo button style
    case white

    /// Logo image name for Venmo button
    public var logoImageName: String? {
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
    public var backgroundColor: Color {
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
    public var hasOutline: Bool {
        switch self {
        case .primary:
            return false
        case .black:
            return false
        case .white:
            return true
        }
    }

    /// Background color when button is tapped
    public var tappedButtonColor: Color {
        switch self {
        case .primary:
            return Color(hex: "#0074FF")
        case .black:
            return Color(hex: "#696969")
        case .white:
            return Color(hex: "#555555")
        }
    }
}
