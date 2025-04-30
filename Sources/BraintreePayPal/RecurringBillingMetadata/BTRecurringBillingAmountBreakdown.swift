import Foundation

/// Provides details to users about their recurring billing amount when using PayPal Checkout with Purchase.
public struct BTRecurringBillingAmountBreakdown {

    // MARK: - Private Properties

    private let itemTotal: String
    private let taxTotal: String
    private let shipping: String?

    // MARK: - Initializer

    /// Initialize a `BTPayPalRecurringAmountBreakdown` object.
    /// - Parameters:
    ///   - itemTotal: Required: Total cost of item(s)
    ///   - shipping: Optional: Cost of shipping
    ///   - taxTotal: Required: Total cost of tax
    public init(
        itemTotal: String,
        taxTotal: String,
        shipping: String? = nil
    ) {
        self.itemTotal = itemTotal
        self.taxTotal = taxTotal
        self.shipping = shipping
    }

    // MARK: - Internal Methods

    func parameters() -> [String: Any] {
        var parameters: [String: Any] = [
            "item_total": itemTotal,
            "tax_total": taxTotal
        ]

        if let shipping {
            parameters["shipping"] = shipping
        }
        
        return parameters
    }
}
