import SwiftUI

public enum PayPalPayLaterButtonColor: PaymentButtonColorProtocol {
    
    /// The default PayPal Pay Later button color
    case blue
    
    /// The black PayPal Pay Later button color
    case black
    
    /// The white PayPal Pay Later button color
    case white
    
    var logoImageName: String? {
        switch self {
        case .blue:
            return "PayLaterLogoBlack"
        case .black:
            return "PayLaterLogoWhite"
        case .white:
            return "PayLaterLogoBlack"
        }
    }
    
    private var paypalButtonColor: PayPalButtonColor {
        switch self {
        case .blue:
            return .blue
        case .black:
            return .black
        case .white:
            return .white
        }
    }
    
    var backgroundColor: Color {
        paypalButtonColor.backgroundColor
    }
    
    var hasOutline: Bool {
        paypalButtonColor.hasOutline
    }
    
    var tappedButtonColor: Color {
        paypalButtonColor.tappedButtonColor
    }
    
    var spinnerColor: String? {
        paypalButtonColor.spinnerColor
    }
}
