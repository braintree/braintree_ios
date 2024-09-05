import Foundation
import PayPalMessages

/// Message location within an application
/// - Warning: This module is in beta. It's public API may change or be removed in future releases.
public enum BTPayPalMessagingPageType {

    /// Home view
    case home

    /// Individual product details view
    case productDetails

    /// Shopping cart view
    case cart

    /// Popover shopping cart view that covers part of the view
    case miniCart

    /// Checkout view
    case checkout

    /// Search results
    case searchResults

    var pageTypeRawValue: PayPalMessagePageType {
        switch self {
        case .home:
            return .home
        case .productDetails:
            return .productDetails
        case .cart:
            return .cart
        case .miniCart:
            return .miniCart
        case .checkout:
            return .checkout
        case .searchResults:
            return .searchResults
        }
    }
}
