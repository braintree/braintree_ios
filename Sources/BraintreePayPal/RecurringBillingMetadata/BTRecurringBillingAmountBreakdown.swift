import Foundation

/// Provides details to users about their recurring billing amount when using PayPal Checkout with Purchase.
public struct BTRecurringBillingAmountBreakdown {

    // MARK: - Private Properties

    private let itemTotal: String
    private let shipping: String
    private let taxTotal: String

    // MARK: - Initializer

    /// Initialize a `BTPayPalRecurringAmountBreakdown` object.
    /// - Parameters:
    ///   - itemTotal: Required: Total cost of item(s)
    ///   - shipping: Optional: Cost of shipping
    ///   - handling: Optional: Cost of handling
    ///   - taxTotal: Optional: Total cost of tax
    ///   - insurance: Optional: Cost of insurance
    ///   - shippingDiscount: Optional: Shipping discount amount
    ///   - discount: Optional: Discount amount
    public init(
        itemTotal: String,
        shipping: String,
        taxTotal: String
    ) {
        self.itemTotal = itemTotal
        self.shipping = shipping
        self.taxTotal = taxTotal
    }

    //MARK: - Internal Methods

    func parameters() -> [String: Any] {
        var parameters: [String: Any] = [
            "item_total": itemTotal,
            "shipping": shipping,
            "taxTotal": taxTotal
        ]
        
        return parameters
    }
}
