import SwiftUI

// MARK: - Payment Button Style Protocol

/// Protocol for payment button styles to share common logic between PayPal and Venmo buttons
protocol PaymentButtonStyleProtocol {
    /// Logo image for the button
    var logoImage: ImageResource? { get }

    /// Background color of the button
    var backgroundColor: Color { get }

    /// Whether the button should have an outline
    var hasOutline: Bool { get }
    
    /// Minimum width needed for the logo to look good with proper padding
    var minimumWidth: CGFloat { get }
}

// MARK: - PayPal Button Style Implementation

/// PayPal payment button style options
public enum BTPaymentButtonStyle: PaymentButtonStyleProtocol {

    /// The primary PayPal button style
    case primaryPayPal

    /// The black PayPal button style  
    case black

    /// The white PayPal button style
    case white

    /// Logo image in the payment
    public var logoImage: ImageResource? {
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
    public var backgroundColor: Color {
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
    public var hasOutline: Bool {
        switch self {
        case .primaryPayPal:
            return false
        case .black:
            return false
        case .white:
            return true
        }
    }

    /// Minimum width for PayPal logo with proper padding
    public var minimumWidth: CGFloat {
        return 131
    }
}
