import Foundation
import PayPalMessages

/// Message location within an application
public enum BTPayPalMessagingPlacement {

    /// Home view
    case home

    /// Category view displaying multiple products
    case category

    /// Individual product view
    case product

    /// Shopping cart view
    case cart

    /// Checkout view
    case payment

    var placementRawValue: PayPalMessagePlacement {
        switch self {
        case .home:
            return .home
        case .category:
            return .category
        case .product:
            return .product
        case .cart:
            return .cart
        case .payment:
            return .payment
        }
    }
}

