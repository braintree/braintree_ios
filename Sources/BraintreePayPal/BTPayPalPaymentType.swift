import Foundation

enum BTPayPalPaymentType: Int {
    
    /// Checkout
    case checkout

    /// Vault
    case vault
    
    var stringValue: String {
        switch self {
        case .vault:
            return "paypal-ba"
        case .checkout:
            return "paypal-single-payment"
        }
    }
}
